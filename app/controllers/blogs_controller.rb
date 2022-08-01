# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :verify_user, only: %i[edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show
    @blog = Blog.viwable(current_user).find(params[:id])
    #blog = Blog.find(params[:id])
    #if !blog.owned_by?(current_user)
    #  @blog = Blog.published.find(params[:id])
    #else
    #  @blog = Blog.my_blog(current_user).find(params[:id])
    #end
  end

  def new
    @blog = Blog.new
  end

  def edit;end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def verify_user
    @blog = current_user.blogs.find(params[:id])
  end

  def blog_params
    if current_user.premium?
      params.require(:blog).permit(:title, :content, :secret, :random_eyecatch)
    else
      params.require(:blog).permit(:title, :content, :secret)
    end
  end
end
