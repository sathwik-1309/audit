# spec/mailers/user_mailer_spec.rb
require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'welcome' do
    let(:name) { 'John Doe' }
    let(:email) { 'john@example.com' }
    let(:mail) { described_class.welcome(name, email) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Welcome to Audit app')
      expect(mail.to).to eq([email])
      expect(mail.from).to eq(['admin@domain.ch'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match("Hello #{name}, hope you enjoy the experience")
    end

    it 'sends the email' do
      expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
