class Admin::ContainersController < Admin::BaseController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @container_pages, @containers = paginate :containers, :per_page => 10
  end
  
  def edit
    @container = Container.find(params[:id])
    @available_chunks = Chunk.find(:all)
    @active = Page.find(:all, :conditions => ["container_id = ?", @container.id], :order => 'position')
  end
  
  def new
    @container = Container.new
  end
  
  def create
    @container = Container.new(params[:container])
    if @container.save
      flash[:notice] = 'Container was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end
  
  def preview
    @container = Container.find(params[:id])
    @page = Page.find(:all, :conditions => ["container_id = ?", @container.id], :order => 'position')
    @chunks = @page.inject([]) {|array,item| array << item.chunk }
  end
    
  def search_chunks
    @search = @params[:search_name]
    @chunks = Chunk.find(:all, :conditions => ["name LIKE ?", "%#{@search}%"])
    respond_to do |type|
      type.js   { render }
    end
  end
  
  def update_chunks
    @container = Container.find(params[:id])
    @page = Page.find(:all, :conditions => ["container_id = ?", @container.id], :order => 'position')
    
    @available_chunks = Chunk.find(:all).inject({}) do |hash, chunk|
      hash[chunk.id] = chunk
      hash
    end
    
    @active = @page.inject({}) do |hash, page|
      hash[page.id] = page
      hash
    end
    
    Page.transaction do
      Page.update_all('position = null')
      @params[:container_box].each_with_index do |id, position|
        status, id = id.split('_')
        id = id.to_i
        if @active.has_key?(id) && status == 'active'
          Page.update(id, { :position => position+1 })
        else
          @new_page = Page.create(:container => @container, :chunk => @available_chunks[id], :position => position+1)
          @new_id = id
        end
      end
      Page.delete_all('position is null')
    end
  end
  
  def remove_chunk
    Page.delete(@params[:id])
  end
end
