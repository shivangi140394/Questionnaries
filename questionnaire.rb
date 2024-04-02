require "pstore" # https://github.com/ruby/pstore

# Constants
STORE_NAME = "tendable.pstore"
QUESTIONS = {
  "q1" => "Can you code in Ruby?",
  "q2" => "Can you code in JavaScript?",
  "q3" => "Can you code in Swift?",
  "q4" => "Can you code in Java?",
  "q5" => "Can you code in C#?"
}.freeze

# Methods

# Method to prompt the user for responses to questions
def do_prompt
  responses = {}
  QUESTIONS.each_key do |question_key|
    print "#{QUESTIONS[question_key]} (Yes/No): "
    ans = gets
    if ans.nil?
      puts "Error: No input received."
      return responses
    end
    ans = ans.chomp.downcase
    unless ['yes', 'no', 'y', 'n'].include?(ans)
      puts "Invalid answer. Please enter Yes or No."
      redo
    end
    responses[question_key] = ans
  end
  responses
end


# Method to calculate the rating for a set of responses
def calculate_rating(responses)
  yes_count = responses.values.count('yes') + responses.values.count('y')
  total_questions = responses.size
  (yes_count.to_f / total_questions * 100).round(2)
end

# Method to report the rating for each run and the overall average rating
def do_report(store)
  total_rating = 0
  store.transaction(true) do
    store["responses"] ||= []
    store["responses"].each do |responses|
      rating = calculate_rating(responses)
      puts "Rating for this run: #{rating}%"
      total_rating += rating
    end
  end
  total_runs = store.transaction { store["responses"].size }
  average_rating = total_runs.positive? ? (total_rating / total_runs).round(2) : 0
  puts "Overall average rating for all runs: #{average_rating}%"
end

# Initialize PStore
store = PStore.new(STORE_NAME)

# Prompt user for responses to questions
responses = do_prompt

# Save responses to PStore
store.transaction do
    store["responses"] ||= [] # Initialize if not already initialized
    store["responses"] << responses
  end

# Report rating for this run and overall average rating
do_report(store)
