class ThemeController < ApplicationController
  def resource
    render :text => '404', :status => 404 and return if params[:filename].to_s.split(%r{[\\/]}).include?("..") or params[:resource].to_s.split(%r{[\\/]}).include?("..")
    mime = mime_type_for(params[:filename].to_s)
    send_file Theme::get_path + '/' + Theme::current + '/resources/' + params[:resource].to_s + '/' + params[:filename].to_s, :type => mime, :disposition => 'inline', :stream => false
  end
  
  private
  def mime_type_for(filename)
    mimes = { /\.js$/   => 'text/javascript',
              /\.css$/  => 'text/css',
              /\.gif$/  => 'image/gif',
              /(\.jpg|\.jpeg)$/ => 'image/jpeg',
              /\.png$/  => 'image/png',
              /\.swf$/  => 'application/x-shockwave-flash',
              /\.txt$/  => 'text/plain'
              }
    mime = nil
    filename.downcase!
    mimes.each { |regex,value| mime = value unless (regex =~ filename).nil? }
    mime = 'application/octet-stream' if mime.nil?
    return mime
  end
end
