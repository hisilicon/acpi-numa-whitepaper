.. _secmemorysidecache:

===============================
Representing Memory-Side Caches
===============================

In a modern heterogenous computing system, there are a number of types
of caching that the operating system should be aware of.

* **CPU/CPU Cluster caches**

  Representation outside of the scope of this document, as they are
  most often reflected in the performance of a particular initiator
  irrespective of the NUMA characteristics of the system.

* **Memory-Side caches**
  
  These are typically physically found somewhere in the path from the
  memory controller to the actual memory elements. In a similar fashion
  to processor caches they can have several levels.

* **Transparent caches in the fabric**

  Some new fabrics, e.g. CCIX, may allow for transparent caches between
  the initiator and the memories point of coherency or home.
  In current Initiator / Target NUMA description these are effectively
  the same as memory-side caches. 

Memory-Side Caches
==================

The Heterogenous Memory Attributes Table HMAT has structures to represent
the nature of these Memory-Side caches and also provide latency and bandwidth
information for all of the elements of the memory system.  The effect these caches
will have on the aggregate NUMA performance is work load dependent.  The
intent of this information is therefore to provide the inputs for detailed
workload modelling or simpler heuristics that can use this information to
improve placement and scheduling decisions.

ACPI Table elements for memory-side caches
==========================================

In order to introduce the ACPI representation of a side cache
system let us first introduce a simple example: :numref:`figsidecache1`.
Here we have two proximity domains. The first contains the host processor and
some directly attached DDR memory.  The second domain contains memory with
a memory-side cache, for example a non-volatile memory with a RAM cache.

.. _figsidecache1:
.. figure:: simplesidecache1.*
    :figclass: align-center

    A straight forward memory-side cache example. Memory 1 might be
    Storage Class Memory with a DDR cache for example.


Memory Side Cache Information Structure
---------------------------------------

This structure provides the Operating System with information on the
type of a given memory-side cache.   Taking the example in :numref:`figsidecache1`
we will see how this works.

.. tabularcolumns:: |p{0.20\linewidth}|>{\centering\arraybackslash}p{0.15\linewidth}|p{0.50\linewidth}|
.. table:: Memory Side Cache Information Structure (HMAT)
    :widths: 70 55 200

    +--------------------+-----------+------------------------------------+
    |    Field           |  Value    |   Notes                            |
    +====================+===========+====================================+
    | Type               | 2         | Memory-Side Cache Information      |
    |                    |           | Structure                          | 
    +--------------------+-----------+------------------------------------+
    | Length             | N         |                                    | 
    +--------------------+-----------+------------------------------------+
    | Memory Proximity   | 1         | This is our new domain with the    |
    | Domain             |           | side cache.                        | 
    +--------------------+-----------+------------------------------------+
    | Cache Attributes   | 0x00802211| 1 Level Cache [3:0] = 1            | 
    |                    |           |                                    | 
    |                    |           | Describing Level 1 [7:4] = 1       | 
    |                    |           |                                    | 
    |                    |           | Complex Cache Indexing [11:8] = 2  | 
    |                    |           |                                    | 
    |                    |           | Write Through [15:12] = 2          | 
    |                    |           |                                    | 
    |                    |           | 128 Byte Cache Line [31:16] = 0x80 | 
    +--------------------+-----------+------------------------------------+
    | No. SMBIOS Handles | 1         |                                    | 
    +--------------------+-----------+------------------------------------+
    | SMBIOS Handle 0    |           | Handle to Physical Memory          |
    |                    |           | Component Structure                | 
    +--------------------+-----------+------------------------------------+

Now we also need to represent the access characteristics of this multi level
memory system.  We shall use the following characteristics.  Unlike in
the original HMAT example, we will assume symmetric characteristics.

* Latency
    - Node 0 Initiator to Local DDR access latency 90 ns.
    - Node 0 Initiator to Node 1 Memory-Side Cache (Level 1) access latency 70 ns.
    - Node 0 Initiator to Node 1 Memory (Level 0) access latency 200 ns.
* Bandwidth
    - Node 0 Initiator to Local DDR access Bandwidth 3200 MB/s
    - Node 0 Initiator to Node 1 Memory-Side Cache (Level 1) access Bandwidth 3200 MB/s
    - Node 0 Initiator to Node 1 Memory (Level 0) access Bandwidth 1600 MB/s
 
 As this is a straight forward SRAT example we will just assume appropriate SRAT
 entries exist.

.. todo:: Shall we provide full examples of the various tables in an appendix?

.. tabularcolumns:: |p{0.20\linewidth}|>{\centering\arraybackslash}p{0.15\linewidth}|p{0.50\linewidth}|
.. table:: Side Cache Example Topology HMAT System Locality Latency and Bandwidth
    Information Structure for memory access latency
    :widths: 70 55 200

    +--------------------+-----------+----------------------------------+
    |    Field           |  Value    |   Notes                          |
    +====================+===========+==================================+
    | Type               | 1         | Identifies this as the "System   |
    |                    |           | Locality Latency and Bandwidth   |      
    |                    |           | Information Structure"           |      
    +--------------------+-----------+----------------------------------+
    | Length             | N         |                                  |      
    +--------------------+-----------+----------------------------------+
    | Flags              | 0         | Memory Hierarchy 0 (the memory)  |
    +--------------------+-----------+----------------------------------+
    | Data Type          | 0         | This table is for memory access  |
    |                    |           | latency.                         |
    +--------------------+-----------+----------------------------------+
    | Number of Initiator| 1         | We have processors which are one |
    | Proximity Domains  |           | type of initiator in Node 0 only.|
    +--------------------+-----------+----------------------------------+
    | Number of Target   | 2         | We have DDR memory in Node 0     |
    | Proximity Domains  |           | and SCM in node 1.               |
    +--------------------+-----------+----------------------------------+
    | Entry Base Unit    |  1000     | 1000 corresponds to units of     |
    |                    |           | nano seconds. We could have used |
    |                    |           | many different units here due to |
    |                    |           | the relatively minor differences |
    |                    |           | in latencies, but 1000 gives     |
    |                    |           | an easy understand scaling.      |
    +--------------------+-----------+----------------------------------+
    | Initiator Proximity| 0         | 1st Initiator Proximity Domain   |          
    | Domain List Entry 0|           | for which we are providing       |
    |                    |           | latency information.             |
    +--------------------+-----------+----------------------------------+
    | Target Proximity   | 0         | 1st Target Proximity Domain      |          
    | Domain List Entry 0|           | for which we are providing       |
    |                    |           | latency information.             |
    +--------------------+-----------+----------------------------------+
    | Target Proximity   | 1         | 2nd Target Proximity Domain      |          
    | Domain List Entry 1|           | for which we are providing       |
    |                    |           | latency information.             |
    +--------------------+-----------+----------------------------------+
    | Entry[0][0]        | 90        | Node 0 to local DDR access       |
    |                    |           | latency, 90ns                    |          
    +--------------------+-----------+----------------------------------+
    | Entry[0][1]        | 200       | Node 0 to Node 1 SCM access      |
    |                    |           | latency, 200ns                   |          
    +--------------------+-----------+----------------------------------+

.. tabularcolumns:: |p{0.20\linewidth}|>{\centering\arraybackslash}p{0.15\linewidth}|p{0.50\linewidth}|
.. table:: Side Cache Example Topology HMAT System Locality Latency and Bandwidth
    Information Structure for cache level 1 access latency
    :widths: 70 55 200

    +--------------------+-----------+----------------------------------+
    |    Field           |  Value    |   Notes                          |
    +====================+===========+==================================+
    | Type               | 1         | Identifies this as the "System   |
    |                    |           | Locality Latency and Bandwidth   |      
    |                    |           | Information Structure"           |      
    +--------------------+-----------+----------------------------------+
    | Length             | N         |                                  |      
    +--------------------+-----------+----------------------------------+
    | Flags              | 1         | Memory Hierarchy 1 (side cache)  |
    +--------------------+-----------+----------------------------------+
    | Data Type          | 0         | This table is for memory-side    |
    |                    |           | cache level 1 access latency     |
    +--------------------+-----------+----------------------------------+
    | Number of Initiator| 1         | We have processors which are one |
    | Proximity Domains  |           | type of initiator in Node 0 only.|
    +--------------------+-----------+----------------------------------+
    | Number of Target   | 1         | We only have a memory-side cache |
    | Proximity Domains  |           | for node 1.                      |
    +--------------------+-----------+----------------------------------+
    | Entry Base Unit    |  1000     | 1000 corresponds to units of     |
    |                    |           | nano seconds. We could have used |
    |                    |           | many different units here due to |
    |                    |           | the relatively minor differences |
    |                    |           | in latencies, but 1000 gives     |
    |                    |           | an easy understand scaling.      |
    +--------------------+-----------+----------------------------------+
    | Initiator Proximity| 0         | 1st Initiator Proximity Domain   |          
    | Domain List Entry 0|           | for which we are providing       |
    |                    |           | latency information.             |
    +--------------------+-----------+----------------------------------+
    | Target Proximity   | 1         | 1st Target Proximity Domain      |          
    | Domain List Entry 0|           | for which we are providing       |
    |                    |           | latency information.             |
    +--------------------+-----------+----------------------------------+
    | Entry[0][0]        | 70        | Node 0 to a hit on the           |
    |                    |           | memory-side cache - latency, 70ns|          
    +--------------------+-----------+----------------------------------+

.. tabularcolumns:: |p{0.20\linewidth}|>{\centering\arraybackslash}p{0.15\linewidth}|p{0.50\linewidth}|
.. table:: Side Cache Example Topology HMAT System Locality Latency and Bandwidth
    Information Structure for memory access bandwidth
    :widths: 70 55 200

    +--------------------+-----------+----------------------------------+
    |    Field           |  Value    |   Notes                          |
    +====================+===========+==================================+
    | Type               | 1         | Identifies this as the "System   |
    |                    |           | Locality Latency and Bandwidth   |      
    |                    |           | Information Structure"           |      
    +--------------------+-----------+----------------------------------+
    | Length             | N         |                                  |      
    +--------------------+-----------+----------------------------------+
    | Flags              | 0         | Memory Hierarchy 0 (the memory)  |
    +--------------------+-----------+----------------------------------+
    | Data Type          | 3         | This table is for memory access  |
    |                    |           | bandwidth.                       |
    +--------------------+-----------+----------------------------------+
    | Number of Initiator| 1         | We have processors which are one |
    | Proximity Domains  |           | type of initiator in Node 0 only.|
    +--------------------+-----------+----------------------------------+
    | Number of Target   | 2         | We have DDR memory in Node 0     |
    | Proximity Domains  |           | and SCM in node 1.               |
    +--------------------+-----------+----------------------------------+
    | Entry Base Unit    | 100       | 100 corresponds to units of      |
    |                    |           | 100 MiB/Sec.                     |
    +--------------------+-----------+----------------------------------+
    | Initiator Proximity| 0         | 1st Initiator Proximity Domain   |          
    | Domain List Entry 0|           | for which we are providing       |
    |                    |           | bandwidth information.           |
    +--------------------+-----------+----------------------------------+
    | Target Proximity   | 0         | 1st Target Proximity Domain      |          
    | Domain List Entry 0|           | for which we are providing       |
    |                    |           | bandwidth information.           |
    +--------------------+-----------+----------------------------------+
    | Target Proximity   | 1         | 2nd Target Proximity Domain      |          
    | Domain List Entry 1|           | for which we are providing       |
    |                    |           | bandwidth information.           |
    +--------------------+-----------+----------------------------------+
    | Entry[0][0]        | 32        | Node 0 to local DDR access       |
    |                    |           | bandwidth, 3200 MiB/Sec          |          
    +--------------------+-----------+----------------------------------+
    | Entry[0][1]        | 16        | Node 0 to Node 1 SCM access      |
    |                    |           | bandwidth, 1600 MiB/Sec          |          
    +--------------------+-----------+----------------------------------+

.. tabularcolumns:: |p{0.20\linewidth}|>{\centering\arraybackslash}p{0.15\linewidth}|p{0.50\linewidth}|
.. table:: Side Cache Example Topology HMAT System Locality Latency and Bandwidth
    Information Structure for cache level 1 access bandwidth
    :widths: 70 55 200

    +--------------------+-----------+----------------------------------+
    |    Field           |  Value    |   Notes                          |
    +====================+===========+==================================+
    | Type               | 1         | Identifies this as the "System   |
    |                    |           | Locality Latency and Bandwidth   |      
    |                    |           | Information Structure"           |      
    +--------------------+-----------+----------------------------------+
    | Length             | N         |                                  |      
    +--------------------+-----------+----------------------------------+
    | Flags              | 1         | Memory Hierarchy 1 (side cache)  |
    +--------------------+-----------+----------------------------------+
    | Data Type          | 3         | This table is for memory-side    |
    |                    |           | cache level 1 access bandwidth.  |
    +--------------------+-----------+----------------------------------+
    | Number of Initiator| 1         | We have processors which are one |
    | Proximity Domains  |           | type of initiator in Node 0 only.|
    +--------------------+-----------+----------------------------------+
    | Number of Target   | 1         | We only have a memory-side cache |
    | Proximity Domains  |           | for node 1.                      |
    +--------------------+-----------+----------------------------------+
    | Entry Base Unit    | 100       | 100 corresponds to units of      |
    |                    |           | 100 MiB/Sec.                     | 
    +--------------------+-----------+----------------------------------+
    | Initiator Proximity| 0         | 1st Initiator Proximity Domain   |          
    | Domain List Entry 0|           | for which we are providing       |
    |                    |           | bandwidth information.           |
    +--------------------+-----------+----------------------------------+
    | Target Proximity   | 1         | 1st Target Proximity Domain      |          
    | Domain List Entry 0|           | for which we are providing       |
    |                    |           | bandwidth information.           |
    +--------------------+-----------+----------------------------------+
    | Entry[0][0]        | 32        | Node 0 to a hit on the           |
    |                    |           | memory-side cache, bandwidth     |
    |                    |           | 3200 MiB/Sec                     |          
    +--------------------+-----------+----------------------------------+

Complex Cases - Shared Caches
------------------------------

In a modern system, it is not unusual to find a complex series of interconnects
between the CPU and coherent *far* memory.   These far memories may have very
different characteristics to local DDR and ACPI provides the means to cleanly
describe these characteristics.

However, these complex system can sometimes throw up cases for which is not
obvious what is the *correct* description in ACPI 6.3. :numref:`figsharedsidecache1`
shows one such example.  Here we have two *expansion memory* devices each of which
has it's own local transparent cache.  These can be described as we did for
:numref:`figsidecache1`.  The system in question has a device responsible for
maintaining cache coherent access to the memories external to the host processor.
This device also has a transparent cache, but in this case it caches memory
from both of the devices behind it.  Conceptually this is similar to how a
multicore processor may have per core L1 cache but share cache at higher levels
across all cores.

.. _figsharedsidecache1:
.. figure:: sharedsidecache1.*
    :figclass: align-center

    A more complex memory-side cache example, including a shared level 2 memory-side
    cache.

In ACPI 6.3 there is no explicit means of representing this sharing. There are three
approaches that a system firmware might use to describe this structure.  Which is
the optimum choice is currently unclear.

1. Combine the two memories and their local caches into a single proximity domain
   with only one set of properties.  This can be represented as a normal memory
   with two levels of memory-side cache.  Unfortunately this obscures any difference
   between the two nodes, and as we shall see in :numref:`figccix1` there can
   be good, system engineering, reasons to represent the fact these memories are
   separate.

2. Pretend we have two caches sized in proportion to the memory behind them.
   This can result in an under estimating potential performance in the case where
   only one of the memories is in use.

3. Pretend there is no contention on the shared cache.  Without contention this
   can be represented as two separate caches, providing the information necessary
   to estimate expected performance as long as the other memory is not in use.

.. _figsharesidecache2:
.. figure:: sharedsidecache2.*
    :figclass: align-center

    The ways in which the memory-side caches in :numref:`figsharedsidecache1` may be
    represented.