class Mailer
  attr_reader :options

  def initialize(opts)
    @options = opts
  end

  def send
    mail_from = options['from']
    mail_to = options['to']&.split(',')
    warn "To: #{mail_to.inspect}"
    envelope_from = options['from'] || options['envelope_from'] || "cli@bounces-dev"

    mail = if options[:data]
      path = File.expand_path(File.join("/data", options[:data]))
      raw = File.read(path)
      warn "Path: #{path}" if options[:verbose]
      Mail.new(raw).tap do |m|
        m.from = mail_from
        m.to = mail_to
        m.smtp_envelope_from = envelope_from if envelope_from && !(envelope_from == mail_from)
      end
    else
      mail = Mail.new do
        from     mail_from
        to       mail_to
        subject  "Test #{Time.now}"
        html_part  do
          body "html"
        end
        text_part do
          body "Test Message\nhttps://www.cloudmailin.com"
        end
      end
    end
    mail.cc = options['cc'].split(',') if options['cc']
    mail.bcc = options['bcc'].split(',') if options['bcc']

    if options['headers']
      options['headers'].each do |k, v|
        warn "Setting header: #{k}: #{v}"
        mail[k] = v
      end
    end

    server_options = get_server_options

    warn "Raw: #{mail.encoded}" if options[:verbose]
    warn "Options: #{server_options.inspect}"
    warn "bcc: #{mail.bcc}, cc: #{mail.cc}, from: #{mail.from}, to: #{mail.to}, #{mail.subject}"
    warn "from: #{mail.from} (#{mail.smtp_envelope_from}), to: #{mail.to}, #{mail.subject}"
    warn "Sending..."

    pool = Concurrent::ThreadPoolExecutor.new(min_threads: 1, max_threads: options[:concurrency],
      max_queue: 1000)
    warn "Pool: #{pool.max_length}"

    mail.delivery_method :smtp, server_options
    times = (options[:times] || 1).to_i
    error_count = 0

    times.times do |i|
      STDERR.write('*')

      pool.post do
        STDERR.write('r')
        response = begin
          response = mail.deliver!
          STDERR.write('✅ ')
          if options[:verbose]
            warn '' # blankline
            warn response.message
          end
        rescue => e
          warn ''
          warn "❌ #{e.message}"
          error_count += 1
        end
      end
    end

    # pool.wait_for_termination
    while pool.completed_task_count < times
      STDERR.write('.')
      exit 1 if error_count > 0 && options[:exit_on_error]
      sleep(1)
    end
  end

  protected

  def get_server_options
    return parse_smtp_url if options[:smtp_url]

    server_options = {
      address: options[:host], port: options[:port], openssl_verify_mode: 'none',
      return_response: true
    }
    server_options[:user_name] = options[:username] if options[:username]
    server_options[:password] = options[:password] if options[:password]
    server_options
  end

  def parse_smtp_url
    url = URI.parse(options[:smtp_url])
    query = URI::decode_www_form(url.query || '').to_h
    {
      address: url.host,
      port: url.port,
      user_name: url.user,
      password: url.password,
      enable_starttls_auto: (query["starttls"] == "true") ? true : false,
      return_response: true,
      openssl_verify_mode: 'none'
    }
  end
end
