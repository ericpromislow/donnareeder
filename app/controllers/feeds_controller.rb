require 'rss'

class FeedsController < ApplicationController  
  before_action :logged_in_user, only: [:create, :destroy, :update]
  before_action :is_admin_user,       only: [:create, :destroy, :update]
  def new
  end

  def index
    @feeds = Feed.paginate(page: params[:page])
  end

  def show
    @feed = Feed.find(params[:id])
    articles = RSS::Parser.parse(@feed.xml_url || @feed.html_url).items
    render json: articles.map {|article| {pubDate: article.pubDate, title: article.title, link: article.link } }
  end

  def create
    @feed = Feed.new(feed_params)
    node = Node.find(params[:feed][:node_id])
    @feed.update(node: node)
    if !@feed.save
      flash[:danger] = "Failed to create feed: #{@feed.errors.full_messages}"
    end
    redirect_to feeds_path
  end

  def update
  end

  def destroy
  end

private

  def feed_params
    params.require(:feed).permit(:feed_type, :xml_url, :html_url, :title)
  end

  def logged_in_user
    return if logged_in?
    flash[:danger] = 'Please log in'
    store_location
    redirect_to feeds_url
  end

  def is_admin_user
    redirect_to feeds_url if !current_user.admin?
  end

end
