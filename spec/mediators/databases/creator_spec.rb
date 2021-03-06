require "spec_helper"

describe Mediators::Databases::Creator do
  let(:params) do
    {
      resource_url: "postgres://user@postgres/db",
      admin_url: "postgres://admin@postgres/db",
      heroku_id: "resource123@herokutest.com",
      plan: "standard-ika",
      app: "pgperf",
      email: "dod@herokumanager.com",
      attachment_name: "HEROKU_POSTGRESQL_PERF_PURPLE",
      description: "Make it better, or cheaper, or both"
    }
  end

  let(:creator) do
    Mediators::Databases::Creator.new(params)
  end

  it "creates a database" do
    database = creator.call
    expect(database.uuid).not_to be(nil)
    expect(database.shogun_name).to eq("shogun-perf")
  end

  it "enqueues a benchmark" do
    allow_any_instance_of(Database).to receive(:enqueue_benchmark)
    creator.call
  end

  it "checks admin url looks like a postgres url" do
    mediator = Mediators::Databases::Creator.new(params.merge({
      admin_url: "https://localhost:5432"
    }))
    expect{mediator.call}.to raise_error(ArgumentError, "admin_url is not a postgres uri")
  end

  it "checks resource url looks like a postgres url" do
    mediator = Mediators::Databases::Creator.new(params.merge({
      resource_url: "https://localhost:5432"
    }))
    expect{mediator.call}.to raise_error(ArgumentError, "resource_url is not a postgres uri")
  end
end

