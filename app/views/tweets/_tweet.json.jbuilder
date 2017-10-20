json.extract! tweet, :id, :author, :body, :created_at, :updated_at
json.url tweet_url(tweet, format: :json)
