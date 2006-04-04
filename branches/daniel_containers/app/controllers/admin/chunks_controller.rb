class Admin::ChunksController < Admin::BaseController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @chunk_pages, @chunks = paginate :chunks, :per_page => 10
  end

  def new
    @chunk = Chunk.new
    @chunk_version = ChunkVersion.new
  end

  def create
    @chunk = Chunk.new(params[:chunk])
    @chunk_version = ChunkVersion.new(params[:chunk_version])
    @chunk.chunk_versions << @chunk_version
    if @chunk.save
      flash[:notice] = 'Chunk was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @chunk = Chunk.find(params[:id])
    @chunk_version = Chunk.find_version(params[:id], params[:version])
  end

  def update
    @chunk = Chunk.find(params[:id])
    @chunk_version = ChunkVersion.new(params[:chunk_version])
    @chunk_version.version = @chunk.latest_version.version + 1
    @chunk_version.base_version = params[:version]
    @chunk.chunk_versions << @chunk_version
    if @chunk.update_attributes(params[:chunk])
      flash[:notice] = 'Chunk was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end
end
