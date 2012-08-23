# -*- coding: utf-8 -*-

require "pp"
require "spec_helper"

describe Megalith, "が #get, :log => 0 を呼ぶ時は" do
  before do
    megalith = Megalith.new("http://coolier.sytes.net:8080/sosowa/ssw_l/")
    @subject = megalith.get :log => 0
  end
  
  it "Megalith::Subjectを返すこと" do
    @subject.class.should == Megalith::Subject
  end

  it "最初のノベルはMegalith::Indexであること" do
    @subject.first.class.should == Megalith::Index
  end

  it "最初のタイトルがStringであること" do
    @subject.first.title.class.should == String
  end

  it "#next_pageがMegalith::Subjectを返すこと" do
    @subject.next_page.class.should == Megalith::Subject
  end

  it "#prev_pageがMegalith::Subjectを返すこと" do
    @subject.next_page.prev_page.class.should == Megalith::Subject
  end

  it "#latest_logがFixnumを返すこと" do
    @subject.latest_log.class.should == Fixnum
  end

  it "最初を#fetchしたらMegalith::Novelを返すこと" do
    @subject.first.fetch.class.should == Megalith::Novel
  end

  it "最初を#fetchしたMegalith::Novel#titleがStringなこと" do
    @subject.first.fetch.title.class.should == String
  end

  it "直接Novelを取得出来ること" do
    log = @subject.first.log
    key = @subject.first.key
    megalith = Megalith.new("http://coolier.sytes.net:8080/sosowa/ssw_l/")
    novel = megalith.get :log => log, :key => key
    novel.class.should == Megalith::Novel
  end
end
