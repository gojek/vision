class UpdateUsersAssociatedAccessRequestsData < ActiveRecord::Migration

  # In quick filter 'relevant to me', records is queried by matching ids in 
  # current user logged in associated by access requests, this script is to populating 
  # table access_requests_associated_users. So every associated AR to user (approver, collabolators, requester)
  # register their id and particular AR in table access_requests_associated_users (for join table, many to many
  # relationship). 
  def up
    execute <<-SQL
      CREATE FUNCTION update_access_requests_associated_users() RETURNS void AS $$
      DECLARE
          access_request RECORD;
          user_id INTEGER;
          approval RECORD;
      BEGIN
          RAISE NOTICE 'POPULATING data access_requests_associated_users';
          FOR access_request IN SELECT * FROM access_requests ORDER BY id LOOP

            EXECUTE 'INSERT INTO access_requests_associated_users (user_id, access_request_id) VALUES (' 
              || access_request.user_id || ', '||  access_request.id || ');';

            FOR approval IN SELECT * FROM 
              access_request_approvals WHERE access_request_id = access_request.id ORDER BY id LOOP

              EXECUTE 'INSERT INTO access_requests_associated_users (user_id, access_request_id) VALUES ('
                || approval.user_id || ', '||  access_request.id || ');';

            END LOOP;

            FOR user_id IN SELECT users.id FROM users INNER JOIN access_request_collaborators 
              ON users.id = access_request_collaborators.user_id 
              WHERE access_request_collaborators.access_request_id = access_request.id GROUP BY users.id LOOP
              
              EXECUTE 'INSERT INTO access_requests_associated_users (user_id, access_request_id) VALUES ('
                || user_id || ', '||  access_request.id || ');';

            END LOOP;

          END LOOP;
          RAISE NOTICE 'Done updating access_requests_associated_users';
      END;
      $$ LANGUAGE plpgsql;

      select update_access_requests_associated_users();
    SQL
  end

  def down
    execute <<-SQL
      TRUNCATE TABLE access_requests_associated_users;
    SQL
  end
end
