require 'test_helper'
require 'minitest/rails/capybara'

class CfpPersonProfileTest < Capybara::Rails::TestCase
  setup do
    @conference = create(:conference)
    @admin = create(:user, person: create(:person), role: 'admin')
    @user = create(:user, person: create(:person), role: 'submitter')

    ActionMailer::Base.deliveries.clear
  end

  teardown do
    ActionMailer::Base.deliveries.clear
  end

  test 'an alert is shown when a non invited user does not have an updated profile' do
    create(:call_for_participation, conference: @conference)

    @user.person.update_attribute(:gender, '')

    login_as(@user)

    assert_text 'You will be able to request an IFF Ticket starting December 10!'
    assert_text 'Please update your user profile to access the ticketing form.'
  end

  test 'an alert is shown when an invited user does not have an updated profile' do
    create(:call_for_participation, conference: @conference)
    create(:invite, email: @user.person.email, conference: @conference)
    create(:attendance_status, person: @user.person, conference: @conference, status: 'Invited')

    @user.person.update_attribute(:gender, '')

    login_as(@user)

    assert_text 'You have been invited to claim an IFF Ticket!'
    assert_text 'Please update your user profile to access the ticketing form.'
  end

  private

  def login_as(user)
    visit '/'

    within '#login' do
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: user.password

      click_on 'Sign in'
    end
  end
end
