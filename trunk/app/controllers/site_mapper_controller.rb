class SiteMapperController < ApplicationController
  
  # Unit tests are required for different urls:
  # '', 'aaa', 'aaa/bbb', etc.
  def show_chunk
    path = @params[:path].to_s
    @chunk_version = SiteMapping.find_chunk(path)
    
    redirect_to :action => 'notfound' unless @chunk_version
  end
  
  # 404 action
  def notfound
  end

  def index
  
  end

  def list
    @chunks_pages, @chunks = paginate :chunks, :per_page => 10
  end

  def show
    @chunks = Chunks.find(params[:id])
  end

  def new
    @chunks = Chunks.new
  end

  def create
    @chunks = Chunks.new(params[:chunks])
    if @chunks.save
      flash[:notice] = 'Chunks was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @chunks = Chunks.find(params[:id])
  end

  def update
    @chunks = Chunks.find(params[:id])
    if @chunks.update_attributes(params[:chunks])
      flash[:notice] = 'Chunks was successfully updated.'
      redirect_to :action => 'show', :id => @chunks
    else
      render :action => 'edit'
    end
  end

  def destroy
    Chunks.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
