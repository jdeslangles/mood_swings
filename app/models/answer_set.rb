class AnswerSet < ActiveRecord::Base
  belongs_to :cohort
  belongs_to :user
  has_many :answers, dependent: :destroy

  scope :with_comments, includes(:answers).where("answers.comments > ''")

  attr_accessible :answers_attributes

  accepts_nested_attributes_for :answers

  validates :cohort_id, presence: true


  def self.populated_with_answers
    answer_set = new
    Metric.active.each do |metric|
      answer_set.answers.build(metric_id: metric.id)
    end
    answer_set
  end

  private
  def chart_color
    @chart_colour ||= "%06x" % (rand * 0xffffff)
  end

  private
  def self.from_last_set_for(user)
    answer_set = populated_with_answers

    return answer_set unless user && last_set = user.answer_sets.last

    answer_set.answers.each do |answer|
      if previous_answer = last_set.answers.detect{|a|a.metric_id==answer.metric_id}
        answer.value = previous_answer.value
      end
    end

    answer_set
  end
end
