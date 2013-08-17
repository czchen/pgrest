``#!/usr/bin/env node``
require! {optimist, plv8x}
require! path
{argv} = optimist

ensured_opts = ->
  unless it.conString
    console.log "ERROR: Please set the PLV8XDB environment variable, or pass in a connection string as an argument"
    process.exit!
  it

get_opts = ->
  if argv.config
    cfg = require path.resolve "#{argv.config}"
  else
    cfg = {}      
  get_db_conn = ->
    if cfg.dbconn and cfg.dbname
      conString = "#{cfg.dbconn}/#{cfg.dbname}"
    else if argv.pgsock
      # what is this???
      conString = do
        host: pgsock
        database: conString      
    else
      conString = argv.db \
        or process.env['PLV8XCONN'] \
        or process.env['PLV8XDB'] \
        or process.env.TESTDBNAME \
        or process.argv?2
  opts = do
    host: argv.host or cfg.host or "127.0.0.1"
    port: argv.port or cfg.port or "3000"
    prefix: argv.prefix or cfg.prefix or "/collections"
    conString: get_db_conn!
    meta: cfg.meta or {}
    schema: argv.schema or cfg.schema or 'public'
  ensured_opts opts

# Main
# --------------------------------------------------------------------
if argv.version
  {version} = require require.resolve \../package.json
  console.log "PgRest v#{version}"
  process.exit 0

opts = get_opts!

pgrest = require \..

plx <- pgrest .new opts.conString, opts.meta
{mount-default,with-prefix} = pgrest.routes!

process.exit 0 if argv.boot

express = try require \express
throw "express required for starting server" unless express
app = express!
require! cors
require! \connect-csv

app.use express.json!
app.use connect-csv header: \guess

cols <- mount-default plx, opts.schema, with-prefix opts.prefix, (path, r) ->
  app.all path, cors!, r

app.listen opts.port, opts.host
console.log "Available collections:\n#{ cols * ' ' }"
console.log "Serving `#{opts.conString}` on http://#{opts.host}:#{opts.port}#{opts.prefix}"
