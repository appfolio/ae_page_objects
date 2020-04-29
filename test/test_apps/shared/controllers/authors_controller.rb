class AuthorsController < ApplicationController
  # GET /authors
  # GET /authors.json
  def index
    @authors = Author.order(:last_name)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @authors }
    end
  end

  class << self
    attr_accessor :last_name_display_delay_ms
  end

  # GET /authors/1
  # GET /authors/1.json
  def show
    @last_name_display_delay_ms = self.class.last_name_display_delay_ms

    @author = Author.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @author }
    end
  end

  # GET /authors/new
  # GET /authors/new.json
  def new
    @author = Author.new
    @author.books.build
    @author.books.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @author }
    end
  end

  # GET /authors/1/edit
  def edit
    @author = Author.find(params[:id])
  end

  # POST /authors
  # POST /authors.json
  def create
    @author = Author.new(params[:author])

    respond_to do |format|
      if @author.save
        format.html { redirect_to @author, :notice => 'Author was successfully created.' }
        format.json { render :json => @author, :status => :created, :location => @author }
      else
        format.html { render :action => "new" }
        format.json { render :json => @author.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /authors/1
  # PUT /authors/1.json
  def update
    @author = Author.find(params[:id])

    respond_to do |format|
      if @author.update_attributes(params[:author])
        format.html { redirect_to @author, :notice => 'Author was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @author.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /authors/1
  # DELETE /authors/1.json
  def destroy
    @author = Author.find(params[:id])
    @author.destroy

    respond_to do |format|
      format.html { redirect_to authors_url }
      format.json { head :ok }
    end
  end
end
