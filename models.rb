require 'digest/md5'
require 'sinatra/activerecord'

class Url < ActiveRecord::Base
  before_create         :gen_url
  validates_presence_of :url
  
  def gen_url
    self.url = Digest::MD5.hexdigest(self.content)
    self
  end
end
