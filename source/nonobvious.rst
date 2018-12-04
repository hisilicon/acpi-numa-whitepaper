========================
Non obvious corner cases
========================

As NUMA systems become more complex, it can become increasingly
difficult to know exactly when certain topologies should be represented
in a particular fashion.   This is ultimately driven by the question of
whether the Operating System or user-space processes may make use of the
information.


When not to merge nodes
=======================

One use the operating system will make of NUMA description is to perform
NUMA memory interleaving.  In this case it can use the ACPI description
to identify suitable memories to interleave data over (often at the Page
or Huge Page level) in order to reduce the pressure on particular elements
of the topology.  Clearly, when it is possible to do such interleaving
in hardware this is normally preferable.  It is common for systems to
perform memory interleaving over all the DDR controllers on a single socket.

However, in some cases the hardware does not support such functionality,
perhaps because these are widely disaggregated components connected to
a coherent fabric. An example is shown in :numref:`figccix1`.

.. _figccix1:

.. figure:: ccixsanodes.*
    :figclass: align-center

    Memory 1 and Memory 2 have identical properties, should we put them in
    one node?

A reasonable firmware design decision, might chose to represent these two
nodes separately despite their identical characteristics.

.. _slitoslimit:

SLIT - Legacy OS limitations
============================

Taking Linux as an example, the following restrictions are applied to SLIT
which are not present under the ACPI specification.

Non local nodes with a local node distance
******************************************

With SLIT alone it seems odd that there might be a situation where
we would like to say that an apparently different NUMA node is at local
distance.  However, the example of deliberately not merging nodes to allow
applications to request software NUMA balancing, shows this is not true.

With the introduction fo HMAT we may want to specify additional nodes
just to describe their memory-side caches, or some really subtle difference.
For operating systems that are still using SLIT it might seem logical to
just have a representation where nodes other than the local are given
distance 10.  However, it seems that Linux rejects this option so it
must be avoided.

Asymmetry
*********

There are some fairly simple topologies that will result in asymmetric
characteristics.  Unfortunately legacy operating systems (Linux for
example) are not setup to allow for this asymmetry if specified in SLIT.
As such it should be avoided.

