class Connection < ActiveRecord::Base
  belongs_to :band
  belongs_to :connected_band, :class_name =>'Band'

  NOT_CONNECTED = 0
  REQUESTED     = 1
  CONNECTED     = 2

  scope :approved, :conditions =>["is_approved = ?", true]

  # creates connection request from first artist to second
  def self.request_connection from_artist, to_artist
    self.create(:band_id =>from_artist.id, :connected_band_id =>to_artist.id)
  end

  # accept the requested connection
  def accept_connection
    self.class.create(:band_id =>self.connected_band_id, :connected_band_id =>self.band_id, :is_approved=>true)
    self.update_attribute(:is_approved, true)
  end

  # remove the established connection
  def remove_connection
    associated_connection = self.class.where(:band_id =>self.connected_band_id, :connected_band_id =>self.band_id).first
    associated_connection.destroy if associated_connection
    self.destroy
  end

  def self.add_connection_between artist1, artist2
    connection            = self.find_or_create_by_band_id_and_connected_band_id(artist1.id, artist2.id)
    associated_connection = connection.associated_connection
    if associated_connection
      associated_connection.update_attribute(:is_approved, true)
      connection.update_attribute(:is_approved, true)
    end    
  end

  def self.remove_connection_between artist1, artist2
    connection_1_2 = self.connection_between artist1, artist2
    connection_2_1 = self.connection_between artist2, artist1
    connection_1_2.remove_connection if connection_1_2
    connection_2_1.remove_connection if connection_2_1
  end

  # connection from artist1 to artist2
  def self.connection_between artist1, artist2
    Connection.where("(band_id = ? and connected_band_id = ?)", artist1.id, artist2.id).first
  end

  def associated_connection
    self.class.find_by_band_id_and_connected_band_id(self.connected_band_id, self.band_id)
  end

  # connection requested from artist1 to artist2
  def self.connection_requested? artist1, artist2
    status = self.connection_status_between artist1, artist2
    status == REQUESTED
  end

  # is connection accepted from artist1 to artist2
  def self.connection_accepted? artist1, artist2
    status = self.connection_status_between artist1, artist2
    status == CONNECTED
  end

  def self.connected? artist1, artist2
    self.connection_accepted? artist1, artist2    
  end

  # returns the connection status [0:not connected, 1:requested, 2:connected
  def self.connection_status_between artist1, artist2
    connection = self.connection_between artist1, artist2
    if connection
      return connection.approved? ? CONNECTED : REQUESTED
    else
      return NOT_CONNECTED
    end
  end

  # all approved connections for particular artist
  def self.approved_connections_for artist
#    Connection.where("(band_id = ?) and is_approved is true", artist.id).page(page).per(ARTIST_CONNECTION_PER_PAGE)
    Connection.where("(band_id = ?) and is_approved is true", artist.id)
  end
  
  # all connection requests for particular artist
  def self.requested_connections_for artist, limit = 0
    if limit > 0
      Connection.where("(connected_band_id = ?) and is_approved is false", artist.id).limit(limit)
    else
      Connection.where("(connected_band_id = ?) and is_approved is false", artist.id)
    end
  end

  def self.connected_artists_with artist, page = 1
    connections         = self.approved_connections_for(artist)
    connected_band_ids  = connections.map{|con| con.connected_band_id}
    Band.where('id in (?)', connected_band_ids ).page(page).per(ARTIST_CONNECTION_PER_PAGE)    
  end

  def approved?
    self.is_approved
  end

  def self.connection_count_for artist
   artist.connections.where('is_approved is true').size
  end
  
end
