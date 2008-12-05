require File.join(File.dirname(__FILE__), 'spec_helper')

describe Sinatra::Hat::Actions, 'children' do
  attr_reader :response, :record

  describe "nesting routes" do
    attr_reader :comment, :comments, :comments_proxy
    
    before(:each) do
      @comment = Object.new
      @comments = []
      @comments_proxy = []
      stub(Post).first(:id => '3').returns(record)
      stub(record).comments.returns(comments_proxy)
      stub(comment).id.returns(2)
      stub(comments_proxy).all.returns(comments)
      stub(comments_proxy).first(:id => '2').returns(comment)
    end
    
    describe "index" do
      it "should generate children json" do
        mock(comments_proxy).all.returns(comments)
        mock(comments).to_json.returns('some-json')
        get_it '/posts/3/comments.json'
        response.should be_ok
        response.body.should include('some-json')
      end
      
      it "should generate children json" do
        mock(comments_proxy).all.returns(comments)
        mock(comments).to_xml.returns('some-xml')
        get_it '/posts/3/comments.xml'
        response.should be_ok
        response.body.should include('some-xml')
      end
      
      it "should render proper template HTML" do
        mock(record).comments.returns(comments_proxy)
        get_it '/posts/3/comments'
        response.should be_ok
        response.body.should include('all-of-em')
      end
    end
    
    describe "new" do
      attr_reader :new_comment
      
      before(:each) do
        @new_comment = Object.new
        stub(new_comment).hello { "The new comment" }
        stub(comments_proxy).new.returns { new_comment }
      end

      it "should generate new action" do
        get_it '/posts/3/comments/new'
        response.should be_ok
      end

      it "assigns a new model object" do
        mock(new_comment).hello
        get_it '/posts/3/comments/new'
      end

      it "should render proper view template" do
        get_it '/posts/3/comments/new'
        body.should == "The new comment"
      end

      it "should return 406 when format unknown" do
        get_it '/posts/3/comments/new.bars'
        response.status.should == 406
      end
    end
    
    describe "show" do
      it "should generate nested json" do
        mock(comments_proxy).first(:id => '2').returns(record)
        mock(record).to_json.returns('some-json')
        mock(record).comments.returns(comments_proxy)
        get_it '/posts/3/comments/2.json'
        response.should be_ok
        response.body.should include('some-json')
      end
      
      it "should generate nested xml" do
        mock(comments_proxy).first(:id => '2').returns(record)
        mock(record).to_xml.returns('some-xml')
        mock(record).comments.returns(comments_proxy)
        get_it '/posts/3/comments/2.xml'
        response.should be_ok
        response.body.should include('some-xml')
      end
      
      it "should render proper template" do
        mock(record).comments.returns(comments_proxy)
        mock(comments_proxy).first(:id => '2').returns(comment)
        get_it '/posts/3/comments/2'
        response.should be_ok
        response.body.should include('railsy-pants')
      end
    end
    
    describe "create" do
      it "should create a child using regular url params" do
        mock(comments_proxy).new.returns(comment)
        mock(comment).attributes = { :post_id => '3', "name" => "Frank" }
        mock(comment).save
        post_it '/posts/3/comments', "comment[name]" => "Frank"
        response.should be_redirection
      end
      
      it "should create a child using json" do
        mock(comments_proxy).new.returns(comment)
        mock(comment).attributes = { "name" => "Frank", "post_id" => '3' }
        mock(comment).save
        post_it '/posts/3/comments.json', "comment" => { "name" => "Frank", "post_id" => '3' }.to_json
        response.should be_ok
      end
      
      it "should create a child using xml" do
        mock(comments_proxy).new.returns(comment)
        mock(comment).attributes = { "name" => "Frank", "post_id" => '3' }
        mock(comment).to_xml.returns('some-xml')
        mock(comment).save
        post_it '/posts/3/comments.xml', "comment" => COMMENT_XML
        response.should be_ok
      end
    end
    
    describe "update" do
      it "should update a record using regular url params" do
        mock(comments_proxy).first(:id => '2').returns(comment)
        mock(comment).attributes = { "name" => "Frank", :post_id => '3' }
        mock(comment).save
        put_it '/posts/3/comments/2', "comment[name]" => "Frank"
        response.should be_redirection
      end
      
      it "should create a child using json" do
        mock(comments_proxy).first(:id => '2').returns(comment)
        mock(comment).attributes = { "name" => "Frank", "post_id" => '3' }
        mock(comment).save
        put_it '/posts/3/comments/2.json', "comment" => { "name" => "Frank", "post_id" => '3' }.to_json
        response.should be_ok
      end
      
      it "should create a child using xml" do
        mock(comments_proxy).first(:id => '2').returns(comment)
        mock(comment).attributes = { "name" => "Frank", "post_id" => '3' }
        mock(comment).to_xml.returns('some-xml')
        mock(comment).save
        put_it '/posts/3/comments/2.xml', "comment" => COMMENT_XML
        response.should be_ok
      end
    end
    
    describe "destroy" do
      it "should destroy a child record" do
        mock(comment).destroy
        delete_it '/posts/3/comments/2'
        response.should be_redirect
      end
    end
  end
end