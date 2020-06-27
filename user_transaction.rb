require 'net/http'
require 'json'
require 'time'

class UserTransactionService
  URL = 'https://jsonmock.hackerrank.com/api/transactions/search'.freeze

  def initialize(uid, txnType, monthYear)
    @uid = uid
    @txnType = txnType
    @monthYear = monthYear
  end

  def call
    transactions = get_valid_transactions
    debit_transactions = @txnType == 'debit' ? transactions : get_debit_transactions
    transactions = filter_transaction_by_average(transactions, debit_transactions)
    transactions.empty? ? [-1] : transactions.sort
  end

  private

  def get_debit_transactions
    @txnType = 'debit'
    get_valid_transactions
  end

  def filter_transaction_by_average(transactions, debit_transactions)
    average = debit_transactions.map(&:last).inject(&:+) / debit_transactions.size
    records = []
    transactions.each do |transaction, amount|
      records << transaction if amount > average
    end
    records
  end

  def get_valid_transactions
    response = get_uri_from_url
    transactions = filter_response_by_dates(response['data'])
    transactions += pull_other_pages_transactions(response) if response['total_pages'].to_i > 1
    transactions
  end

  def filter_response_by_dates(data)
    records = []
    data.each do |transaction|
      if start_time <= transaction['timestamp'].to_i && transaction['timestamp'].to_i <= end_time
        records << [transaction['id'], parse_amount(transaction['amount'])]
      end
    end
    records
  end

  def pull_other_pages_transactions(response)
    records = []
    (2..response['total_pages'].to_i).each do |page|
      response = get_uri_from_url(page)
      records += filter_response_by_dates(response['data'])
    end
    records
  end

  def get_uri_from_url(page = 1)
    uri = URI(URL)
    uri.query = URI.encode_www_form(parameters(page))
    JSON.parse(Net::HTTP.get_response(uri).body)
  end

  def parameters(page)
    parameters = {}
    parameters[:page] = page
    parameters[:userId] = @uid if @uid
    parameters[:txnType] = @txnType if @txnType
    parameters
  end

  def start_time
    month, year = @monthYear.split('-')
    @start_time ||= Time.parse("01-#{month}-#{year} 00:00:00 UTC").to_i * 1000
  end

  def end_time
    month, year = @monthYear.split('-')
    month = month.to_i == 12 ? 1 : month.to_i + 1
    year = month.to_i == 12 ? year.to_i + 1 : year
    @end_time ||= (Time.parse("01-#{month}-#{year} 00:00:00 UTC") - 1).to_i * 1000
  end

  def parse_amount(amount)
    amount.gsub('$', '').gsub(',', '').to_f
  end
end

puts UserTransactionService.new(3, "credit", "03-2019").call
# puts UserTransactionService.new(4, "credit", "01-2019").call
# puts UserTransactionService.new(1, "credit", "05-2019").call
# puts UserTransactionService.new(2, "credit", "01-2019").call
# puts UserTransactionService.new(1, "credit", "09-2019").call
