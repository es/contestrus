require 'test_helper'

class CompetitionsIntegrationTest < ActionDispatch::IntegrationTest
  test "show all competitions when signed in" do
    user = sign_in

    within "#sidebar" do
      assert page.has_content?(competitions(:open).name)
      assert page.has_content?(competitions(:ongoing).name)
    end
  end

  test "view a competition's tasks" do
    user = sign_in

    task = competitions(:open).tasks.first

    within "#sidebar" do
      assert page.has_content?(task.name), 
        "Page doesn't have task #{task.name}"
    end
  end

  test "user who has not submitted should not show up on the leaderboard" do
    user = sign_in
    competition = competitions(:ongoing)

    visit leaderboard_competition_path(competition)

    within "#content" do
      refute page.has_content?(user.username)
    end
  end

  test "user who has submitted should show up on the leaderboard" do
    user = sign_in

    competition = competitions(:ongoing)

    within "#sidebar" do
      click_link tasks(:ongoing_hello_world).name
    end

    attach_file "submission_source", Rails.root + "test/data/submissions/hello_world.rb"
    click_button "Evaluate"

    visit leaderboard_competition_path(competition)

    within "#content" do
      assert page.has_content?(user.username.humanize), 
        "Should show user #{user.username} on leaderboard after submitting solution to task."
    end
  end

  test "user who has submitted successful one group solution should not show points on the leaderboard" do
    user = sign_in

    competition = competitions(:ongoing)
    task = tasks(:ongoing_hello_world)

    within "#sidebar" do
      click_link task.name
    end

    attach_file "submission_source", Rails.root + "test/data/submissions/hello_world.rb"
    click_button "Evaluate"

    visit leaderboard_competition_path(competition)

    within "#leaderboard" do
      assert page.has_content?(task.points),
        "Should show user #{user.username}'s points on leaderboard after submitting solution to task."
      assert page.has_content?("Passed"),
        "Should show user #{user.username}'s passed submitting solution to task."
    end
  end

  test "user who has submitted successful multi-group solution should show points on the leaderboard" do
    user = sign_in

    task = tasks(:ongoing_sum)

    within "#sidebar" do
      click_link task.name
    end

    attach_file "submission_source", Rails.root + "test/data/submissions/sum.rb"
    click_button "Evaluate"

    within "#content" do
      assert page.has_content?(task.points),
        "Should show user #{user.username}'s points on leaderboard after submitting solution to task."
      assert page.has_content?("Passed"),
        "Should show user #{user.username}'s passed submitting solution to task."
    end
  end

  test "user who has partial multi-group solution should show points on the leaderboard" do
    user = sign_in

    task = tasks(:ongoing_sum)

    within "#sidebar" do
      click_link task.name
    end

    attach_file "submission_source", Rails.root + "test/data/submissions/sum_2.rb"
    click_button "Evaluate"

    within "#content" do
      assert page.has_content?(task.groups.second.points),
        "Should show user #{user.username}'s points on leaderboard after submitting solution to task."
      assert page.has_content?("Partial"),
        "Should show user #{user.username}'s passed submitting solution to task."
    end
  end

  test "browsing to a competition that has yet to start does not reveal any information" do
    user = sign_in
    competition = competitions(:future)

    within "#sidebar" do
      refute page.has_content?(tasks(:future_hello_world).name), 
        "Should not see tasks when contest has yet to start."
    end
  end

  test "normal user can browse to leaderboard of expired competition" do
    user = sign_in(users(:bob))

    competition = competitions(:past)

    within "#sidebar" do
      assert_selector "a", text: competition.name
    end
  end

  test "normal user cannot browse to leaderboard of ongoing competition" do
    user = sign_in(users(:bob))

    competition = competitions(:ongoing)

    within "#sidebar" do
      assert_no_selector "a", text: competition.name
    end
  end

  test "when not signed in no competitions should be shown" do
    competition = competitions(:ongoing)

    within "#sidebar" do
      assert_no_selector "li", text: competition.name
    end
  end
end
