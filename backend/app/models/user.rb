class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  acts_as_token_authenticatable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :accounts
  has_many :mops
  has_many :cards
  has_many :transactions
  has_many :categories
  has_many :sub_categories

  after_commit :after_save_action, on: [:create, :update]

  def after_save_action
    Websocket.publish(USER_CHANNEL, 'refresh')
  end

  def debitcards
    self.cards.where(ctype: DEBITCARD)
  end

  def creditcards
    self.cards.where(ctype: CREDITCARD)
  end

  def send_reset_password_otp
    otp = rand(100_0..999_9)
    begin
      self.meta['reset_password_otp'] = [] if self.meta['reset_password_otp'].nil?
      self.meta['reset_password_otp'] << otp
      self.save!
      UserMailer.reset_password_otp(self.email, otp).deliver_now
    rescue StandardError => ex
      puts ex.message
    end
  end

  def upload(image)
    uploaded_file = image

    if uploaded_file.blank?
      render_400("Empty file upload") and return
    end

    # Construct the filename based on user_id or any desired logic
    filename = "user_#{self.id}.jpg"

    # Determine the directory where you want to save the file
    upload_directory = Rails.root.join('public', 'images')

    # Ensure the directory exists; create it if it doesn't
    FileUtils.mkdir_p(upload_directory) unless File.directory?(upload_directory)

    # Build the full file path
    file_path = File.join(upload_directory, filename)

    begin
      # Save the uploaded file to the specified directory
      File.open(file_path, 'wb') do |file|
        file.write(uploaded_file.read)
      end

      # Update the user's image_url
      self.image_url = filename
      self.save!
    rescue => e
      Rails.logger.error("Error saving file: #{e.message}")
      raise StandardError.new(e.message)
    end
  end

end
