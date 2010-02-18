require 'test_helper'

class TwoChThread < ActiveRecord::Base
  has_many :responses
  acts_as_sequenced :column => :th_no
end

class Response < ActiveRecord::Base
  belongs_to :two_ch_thread
  acts_as_sequenced :column => :response_no, :scope => :two_ch_thread
  if self.respond_to? :acts_as_paranoid
    acts_as_paranoid
  end
end

class NonSequenced < ActiveRecord::Base
end

class ActsAsSequencedTest < ActiveSupport::TestCase
  test "should be numbered" do
    th1 = TwoChThread.create!(:title => "[rails] acts_as_sequenced [plugin]")
    assert_equal 1, th1.th_no
    th2 = TwoChThread.create!(:title => "what is the best rails plugin")
    assert_equal 2, th2.th_no
    th3 = TwoChThread.create!(:title => "ruby? ..Ah! It\'s what Rails needs, isn\'t it?")
    assert_equal 3, th3.th_no
  end


  test "should be numbered only in scope" do
    th = TwoChThread.create(:title => "[rails] acts_as_sequenced [plugin]")
    th.save
    r1 = th.responses.create!(:content => "acts_as_sequenced is so nice!!")
    assert_equal 1, r1.response_no
    r2 = th.responses.create!(:content => "hagedou")
    assert_equal 2, r2.response_no
    r3 = th.responses.create!(:content => "itteyosi")
    assert_equal 3, r3.response_no

    th = TwoChThread.create(:title => "[logical] acts_as_paranoid [delete]")
    r1 = th.responses.create!(:content => "When should I use logical delete?")
    assert_equal 1, r1.response_no
    r2 = th.responses.create!(:content => "acts_as_paranoid is no nice!!!!!")
    assert_equal 2, r2.response_no
  end

  test "should be numbered even when deleted objects exist" do
    th1 = TwoChThread.create!(:title => "[rails] acts_as_sequenced [plugin]")
    assert_equal 1, th1.th_no
    th1.destroy
    th2 = TwoChThread.create!(:title => "what is the best rails plugin")
    assert_equal 1, th2.th_no
    th3 = TwoChThread.create!(:title => "ruby? ..Ah! It\'s what Rails needs, isn\'t it?")
    assert_equal 2, th3.th_no
    th2.destroy
    th4 = TwoChThread.create!(:title => "What can I prepare for Rails 3.0?")
    assert_equal 3, th4.th_no
  end

  if Response.respond_to?(:paranoid?) && Response.paranoid?
    test "should be numbered even when deleted objects exist (with logical delete)" do
      th = TwoChThread.create!(:title => "[rails] acts_as_sequenced [plugin]")

      r1 = th.responses.create!(:content => "Have you used it?")
      assert_equal 1, r1.response_no
      r1.destroy
      r2 = th.responses.create!(:content => "It's useful.")
      assert_equal 2, r2.response_no
      r3 = th.responses.create!(:content => "OMG!!!! >>1 is already deleted! What did >>1 mean?")
      assert_equal 3, r3.response_no
      r2.destroy
      r4 = th.responses.create!(:content => "aboon aboon aboon aboon")
      assert_equal 4, r4.response_no
    end
  end

  test "should give sequenced status" do
    assert TwoChThread.sequenced?
    assert !NonSequenced.sequenced?
  end

protected
  def create_thread
    th = TwoChThread.create
    th.title = "aaa"
    th.save
    r = th.responses.create
    r.content = "hogehoge"
    r.save
  end
end
