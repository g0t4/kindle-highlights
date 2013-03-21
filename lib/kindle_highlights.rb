require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'amazon/aws'
require 'amazon/aws/search'
require 'kindle_highlights/backup'
require 'kindle_highlights/parser'
require 'json'

include Amazon::AWS
include Amazon::AWS::Search