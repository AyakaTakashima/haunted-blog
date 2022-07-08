# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[show edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show
    raise ActiveRecord::RecordNotFound if @blog.secret? && !@blog.owned_by?(current_user)
  end

  def new
    @blog = Blog.new
  end

  def edit
    raise ActiveRecord::RecordNotFound if !@blog.owned_by?(current_user)
  end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if !@blog.owned_by?(current_user)
      raise ActiveRecord::RecordNotFound
    elsif @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if !@blog.owned_by?(current_user)
      raise ActiveRecord::RecordNotFound
    else
      @blog.destroy!
  
      redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
    end
  end

  private

  def set_blog
    if current_user.nil?
      @blog = Blog.where(secret: false).find(params[:id])
    else
      @blog = Blog.find(params[:id])
    end
  end

  def blog_params
    if current_user.premium?
      params.require(:blog).permit(:title, :content, :secret, :random_eyecatch)
    else
      params.require(:blog).permit(:title, :content, :secret)
    end
  end
end
