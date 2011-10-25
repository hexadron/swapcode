require 'digest/md5'
require 'sinatra/activerecord'

class Url < ActiveRecord::Base
  after_initialize        :gen_url
  validates_presence_of   :url
  validates_uniqueness_of :url
  
  def gen_url
    unless self.url
      self.url = Digest::MD5.hexdigest(Time.now.to_s)
    end
    self
  end
end