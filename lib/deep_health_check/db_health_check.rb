# frozen_string_literal: true

module DeepHealthCheck
  class DBHealthCheck < HealthCheck
    def call
      respose(db_active_record.merge(db_delayed_jobs))
    end

    private

    def respose(data)
      api_health_check 200, "connected": data[:connected],
                            "tables": data[:tables].to_s,
                            "max_connection_size": data[:db_size].to_s,
                            "open_connection": data[:db_conn_size].to_s,
                            "dj_total_count": data[:dj_count].to_s,
                            "dj_faild_count": data[:faild_dj_count].to_s,
                            "dj_terminated_count": data[:terminated_count].to_s
    end

    def db_active_record
      data = {}
      data[:tables] = ActiveRecord::Base.connection.tables.count
      data[:connected] = ActiveRecord::Base.connected?
      data[:db_size] = ActiveRecord::Base.connection_pool.size
      data[:db_conn_size] = ActiveRecord::Base.connection_pool.connections.size
      data
    rescue StandardError
      {}
    end

    def db_delayed_jobs
      data = {}
      data[:dj_count] = Delayed::Job.count
      data[:terminated_count] = Delayed::Job.where.not(failed_at: nil).count
      data[:faild_dj_count] = Delayed::Job.where(failed_at: nil)
                                          .where('attempts > 0').count
    rescue StandardError
      {}
    end
  end
end
