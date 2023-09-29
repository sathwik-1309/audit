class ImageController < ApplicationController
  before_action :check_current_user

  def profile_pic
    if @current_user.nil?
      render_202("User not found") and return
    end
    # Determine the directory where your images are stored
    images_directory = Rails.root.join('public', 'images')
    filepath = File.join(images_directory, "#{@current_user.image_url}")

    # Check if the file exists
    if File.exist?(filepath)
      # Serve the file
      send_file(filepath, type: 'image/jpeg', disposition: 'inline')
    else
      # Return a 404 response or handle it as you prefer
      send_file(File.join(images_directory, 'empty_user.webp'), type: 'image/jpeg', disposition: 'inline')
    end
  end
  
end