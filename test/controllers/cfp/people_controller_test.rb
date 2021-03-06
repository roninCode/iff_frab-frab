require 'test_helper'

class Cfp::PeopleControllerTest < ActionController::TestCase
  setup do
    user = login_as(:submitter)
    @cfp_person = user.person
    @call_for_participation = create(:call_for_participation)
    @conference = @call_for_participation.conference
  end

  def cfp_person_params
    @cfp_person.attributes.except(*%w(id avatar_file_name avatar_content_type avatar_file_size avatar_updated_at created_at updated_at user_id note))
  end

  test 'should get new' do
    get :new, conference_acronym: @conference.acronym
    assert_response :success
  end

  test 'should create cfp_person' do
    # can't have two persons on one user, so delete the one from login_as
    user = create(
      :user,
      role: 'submitter'
    )
    user.person = nil
    session[:user_id] = user.id

    @cfp_person.email = generate(:email)

    assert_difference 'Person.count' do
      post :create, person: cfp_person_params, conference_acronym: @conference.acronym
    end
    assert_response :redirect
  end

  test 'should get edit' do
    get :edit, conference_acronym: @conference.acronym
    assert_response :success
  end

  test 'should update cfp_person' do
    @cfp_person.email = generate(:email)

    put :update, id: @cfp_person.id, person: cfp_person_params, conference_acronym: @conference.acronym
    assert_response :redirect
  end

  test 'redirects other conferences to current one' do
    create(:conference, acronym: 'MYCONF')

    ENV['CURRENT_CONFERENCE'] = 'MYCONF'

    get :show, conference_acronym: @conference.acronym

    assert_redirected_to cfp_root_path(conference_acronym: 'MYCONF')
  end
end
