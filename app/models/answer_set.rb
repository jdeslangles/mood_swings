class AnswerSet < ActiveRecord::Base
  belongs_to :user
  has_many :answers

  attr_accessible :answers_attributes

  accepts_nested_attributes_for :answers

  def self.populated_with_answers
    answer_set = new
    Metric.all.each do |metric|
      answer_set.answers.build(metric_id: metric.id)
    end
    answer_set
  end

  def chart_data
    data = { timestamp: created_at.strftime('%Y-%m-%d %H:%M:%S') }
    answers.each do |answer|
      data["#{user.id}##{answer.metric.id}"] = answer.value
    end
    data
  end


  def chart_data_label_keys
    answers.map do |answer|
      # '"' + user.id.to_s + '#' + answer.metric.id.to_s + '"'
      user.id.to_s + '#' + answer.metric.id.to_s
    end
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