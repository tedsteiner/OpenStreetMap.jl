Data Types
==========
This page gives an overview of the main data types used by OpenStreetMap.jl.

Map Data
---------
These types pertain directly to map elements.

Highway
^^^^^^^^^^^^^^
All roads and paths in OpenStreetMap are generically called “highways.” These types must include a list of nodes that comprises the path of the highway. All other fields are optional, and are empty strings when missing from the OSM database.

When a highway is labeled as “oneway,” the road or path is only legally traversable in the order in which the nodes are listed.

.. code-block:: python

    type Highway
        class::String       # Type of highway
        lanes::Int          # Number of lanes (1 if unspecified)
        oneway::Bool        # True if road is one-way
        sidewalk::String    # Sidewalk classifier, if available
        cycleway::String    # Cycleway classifier, if available
        bicycle::String     # Bicycle classifier, if available
        name::String        # Name, if available
        nodes::Vector{Int}  # List of nodes
    end

"Segments" represent a subset of a highway, and can be used for faster route
planning. They begin and end at highway intersections (see below). Segments can
be extracted from a list of roads and intersections using "extractSegments()."

.. code-block:: python


    type Segment
        node0::Int          # Source node ID
        node1::Int          # Target node ID
        nodes::Vector{Int}  # List of nodes falling within node0 and node1
        class::Int          # Class of the segment
        parent::Int         # ID of parent highway
        oneway::Bool        # True if road is one-way
    end


Feature
^^^^^^^^^^^^^^
“Features” are nodes tagged with additional data. OpenStreetMap.jl currently ignores some of these tags (e.g., crosswalks), but the following feature classes are currently extracted from OSM files:
    * amentity
    * shop
    * building
    * craft
    * historic
    * sport
    * tourism

Many of these features also have a specified name and class detail (e.g., shop:restaurant). Nodes with no tags are never made into features.

.. code-block:: python

    type Feature
        class::String       # Shop, amenity, crossing, etc.
        detail::String      # Class qualifier
        name::String        # Name
    end

Building
^^^^^^^^^^^^^^
Buildings in OpenStreetMap may optionally have a name and class (though typically buildings are unlabeled). Like highways, they include a list of nodes.

.. code-block:: python

    type Building
        class::String       # Building type (usually "yes")
        name::String        # Building name (usually unavailable)
        nodes::Vector{Int}  # List of nodes
    end

Intersection
^^^^^^^^^^^^^^
OpenStreetMap.jl includes an intersection detector. An intersection is a node which is included in at least two highways’ lists of nodes. The intersection object maintains a ``Set`` (no duplicates allowed) of highway ids that use that node.

.. code-block:: python

    type Intersection
        highways::Set{Int} # Set of highway IDs
    end

Region Boundaries
^^^^^^^^^^^^^^^^^^
Region boundaries include the minimum and maximum latitude and longitude of a region. While the names of the types are clearly focused on the LLA coordinate system, Bounds can also be used with ENU coordinates. They will not work well with ECEF coordinates.

.. code-block:: python

    type Bounds
        min_lat    # Or min_north
        max_lat    # Or max_north
        min_lon    # Or min_east
        max_lon    # Or max_east
    end

Point Types
--------------
These types give alternative representations for point locations in OpenStreetMap.jl.

Latitude-Longitude-Altitude (LLA) Coordinates
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Used to store node data in OpenStreetMap XML files.

.. code-block:: python

    type LLA
        lat
        lon
        alt
    end

Because OpenStreetMap typically does not store altitude data, the following alias is available for convenience:
``LLA(lat, lon) = LLA(lat, lon, 0)``

Earth-Centered-Earth-Fixed (ECEF) Coordinates
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Global cartesian coordinate system rotating with the Earth.

.. code-block:: python

    type ECEF
        x
        y
        z
    end

East-North-Up (ENU) Coordinates
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Local cartesian coordinate system, centered on a reference point.

.. code-block:: python

    type ENU
        east
        north
        up
    end

Additional Types
----------------

Transportation Network
^^^^^^^^^^^^^^^^^^^^^^

The Network type is used to represent a street transportation network as a graph. This type nicely encapsulates the graph data from the user, simplifying the use of Graphs.jl for route planning. Most users will not need to interact with the internals of these objects.

.. code-block:: python

    type Network
        g        # Incidence graph of streets
        v        # Dictionary of vertices
        v_inv    # Inverted list of vertices
        w        # Edge weights
        class    # Edge classification
    end

Plot Styles
^^^^^^^^^^^

The ``Style`` type is used to define custom plot elements. More information on its usage can be found on the Plots page.

.. code-block:: python

    type Style
        color::Uint32   # Line color
        width::Real     # Line width
        spec::String    # Line type
    end

    style(x, y) = style(x, y, "-")



