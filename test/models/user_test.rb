require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "create user" do
    assert_difference 'User.count', +1 do
      User.create(valid_params)
    end
  end

  test "validates presence of username" do
    user = User.new(valid_params.merge(username: nil))
    assert_invalid user
  end

  test "validates presence of password" do
    user = User.new(valid_params.merge(password: nil))
    assert_invalid user
  end

  test "validates minimum length of password" do
    user = User.new(valid_params.merge(password: "hakme"))
    assert_invalid user
  end

  test "validates uniqueness of a username" do
    first = User.first
    user = User.new(valid_params.merge(username: first.username))
    assert_invalid user
  end

  test "validates presence of email" do
    user = User.new(valid_params.merge(email: nil))
    assert_invalid user
  end

  test "validates uniqueness of an email" do
    first = User.first
    user = User.new(valid_params.merge(email: first.email))
    assert_invalid user
  end

  test "sets a session hash on creation" do
    user = User.new(valid_params)
    assert_predicate user.session_hash, :nil?
    user.save
    assert_match /\A[a-f0-9]{16}\z/, user.session_hash
  end

  private
  def valid_params
    {
      username: "Simon Hørup Eskildsen",
      password: "seekrit",
      email: "simon@sirupsen.com"
    }
  end
end
