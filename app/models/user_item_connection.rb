class UserItemConnection < ActiveRecord::Base
  belongs_to :useritem, :polymorphic =>true
  belongs_to :connected_useritem, :polymorphic =>true

  NOT_CONNECTED = 0
  REQUESTED     = 1
  CONNECTED     = 2

  scope :approved, :conditions =>["is_approved = ?", true]

  # creates connection request from first user-item to second
  def self.request_connection from_item, to_item
    self.create(:useritem_type =>from_item.class.name, :useritem_id =>from_item.id, :connected_useritem_type =>to_item.class.name, :connected_useritem_id =>to_item.id)
  end

  # accept the requested connection
  def accept_connection
    self.class.create(:useritem_type =>self.connected_useritem_type, :useritem_id =>self.connected_useritem_id, :connected_useritem_type =>self.useritem_type, :connected_useritem_id =>self.useritem_id, :is_approved=>true)
    self.update_attribute(:is_approved, true)
  end

  # remove the established connection
  def remove_connection
    associated_connection = self.class.where(:useritem_type =>self.connected_useritem_type, :useritem_id =>self.connected_useritem_id, :connected_useritem_type =>self.useritem_type, :connected_useritem_id =>self.useritem_id).first
    associated_connection.destroy if associated_connection
    self.destroy
  end

  def self.add_connection_between useritem1, useritem2
    connection            = self.find_or_create_by_useritem_type_and_useritem_id_and_connected_useritem_type_and_connected_useritem_id(useritem1.class.name, useritem1.id, useritem2.class.name, useritem2.id)
    associated_connection = connection.associated_connection
    if associated_connection
      associated_connection.update_attribute(:is_approved, true)
      connection.update_attribute(:is_approved, true)
    end
  end

  def self.remove_connection_between useritem1, useritem2
    connection_1_2 = self.connection_between useritem1, useritem2
    connection_2_1 = self.connection_between useritem2, useritem1
    connection_1_2.remove_connection if connection_1_2
    connection_2_1.remove_connection if connection_2_1
  end

  # connection from artist1 to artist2
  def self.connection_between useritem1, useritem2
    Connection.where("(useritem_type = ? and useritem_id = ? and connected_useritem_type = ? and connected_useritem_id = ?)",useritem1.class.name, useritem1.id, useritem2.class.name, useritem2.id).first
  end

  def associated_connection
    self.class.find_by_artist_id_and_connected_artist_id(self.connected_artist_id, self.artist_id)
  end

  # connection requested from useritem1 to useritem2
  def self.connection_requested? useritem1, useritem2
    status = self.connection_status_between useritem1, useritem2
    status == REQUESTED
  end

  # is connection accepted from useritem1 to useritem2
  def self.connection_accepted? useritem1, useritem2
    status = self.connection_status_between useritem1, useritem2
    status == CONNECTED
  end

  def self.connected? useritem1, useritem2
    self.connection_accepted? useritem1, useritem2
  end

  # returns the connection status [0:not connected, 1:requested, 2:connected
  def self.connection_status_between useritem1, useritem2
    connection = self.connection_between useritem1, useritem2
    if connection
      return connection.approved? ? CONNECTED : REQUESTED
    else
      return NOT_CONNECTED
    end
  end

  # all approved connections for particular artist
  def self.approved_connections_for useritem
#    Connection.where("(artist_id = ?) and is_approved is true", artist.id).page(page).per(ARTIST_CONNECTION_PER_PAGE)
    Connection.where("(useritem_type = ? and useritem_id = ?) and is_approved is true", useritem.class.name, useritem.id)
  end

  # all connection requests for particular useritem
  def self.requested_connections_for useritem, limit = 0
    if limit > 0
      Connection.where("(connected_useritem_type = ? and connected_useritem_id = ?) and is_approved is false",useritem.class.name, useritem.id).limit(limit)
    else
      Connection.where("(connected_useritem_type = ? and connected_artist_id = ?) and is_approved is false", useritem.class.name, useritem.id)
    end
  end

  #[TODO]
  def self.connected_useritems_with useritem, page = 1
#    connections           = self.approved_connections_for(useritem)
#    connected_artist_ids  = connections.map{|con| con.connected_useritem_id}
#    Artist.where('id in (?)', connected_artist_ids ).page(page).per(ARTIST_CONNECTION_PER_PAGE)
  end

  def approved?
    self.is_approved
  end

  def self.connection_count_for useritem
   useritem.connections.where('is_approved is true').size
  end
end
