json.array!(@access_request_comments) do |access_request_comment|
  json.extract! access_request_comment, :id, :body, :access_request_id, :user_id
  json.url access_request_comment_url(access_request_comment, format: :json)
end
