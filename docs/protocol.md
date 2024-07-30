# OCNet Protocol (OCNP)

The OCNet Protocol (OCNP) is the underlying mechanism behind OCNet.

## Packets

OCNP compliant programs send packets between eachother to communicate.

A typical OCNP packet is structured like so:

`['.ocnp.',[sender-uuid:port, receiver-uuid:port, packet-uuid, packet-sequence, packet-number], [metadata], [payload]]`

This can be broken down into the following:

* `'.ocnp.'` - OCNP header to identify that OCNP is being used
* `sender-uuid` - the UUID of the network card that sent the packet
* `receiver-uuid` - the UUID of the network card at the intended destination of the packet
* `port` - port of the message for the sender and receiver respectively
* `packet-uuid` - a one-time generated UUID to identify a series of packets
* `packet-sequence` - the ID of the packet in the series of packets
* `packet-number` - the number of packets total in the series of packets
* `metadata` - any data that can be sent that isn't part of the proper payload, at developer discretion
* `payload` - the data itself, at developer discretion

Remember that OpenComputers network cards cannot send arrays over networks. Remember to serialize information before sending.

Metadata can be paritcularly useful for networks that may want to implement security (such as checksums) or priority queueing.

### Series of packets

Sometimes, not all information can be conveyed in a single payload. Therefore, the computer must send a series of packets.

Programs will identify a series of packets by a common UUID, store all the packets in memory, and then combine the payloads together by order of packet sequence to get the final data.

### ACKs

Programs should send an acknowledgement of receiving the packet (ACKs) when they receive the packet. If a program does not receive an ACK, it will resend the message in 5 seconds before timing out. Masts also send ACKs for load distribution, this will be explained later.

ACKs can also be used to reject packets.

ACKs are structured like so:

`['.ocnp.ack.....',rejected]`

The first section is a header to let OCNP-compliant programs know that it is an ACK.

The second one is a boolean, i.e. `true` or `false`, to see if the receiver accepted or rejeceted the packet.


## Topology

OCP follows a tree topology - that is, clients (end user programs) connected to hubs (masts). The masts themselves connect to a few network centres via linked cards to enable a single network across the entire server, no matter the size.

### Masts

Packets are send through masts which will relay to eachother, either via a linked card or a wireless card. Here, a "mast" is any program with the `mast.lua` program (see the programs folder) which forwards packets.

Masts continuously give a discovery broadcast everytime the Unix time is divisible by five. This is so they all send at the same time. Because there is a short delay when relaying packets through a relay, the discovery broadcast of the mast serving a region will arrive in that region before the other #masts do.

Computers will figure out which mast to send to by reading `/home/.mast-uuid` on the computer. If the file does not work, or it cannot read the file (for example, it does not exist), then the program will listen for such a discovery broadcast and write the first discovery broadcast it finds to `/home/.mast-uuid`.

Because OpenComputers drops packets after five relays, the program will actually send the packet to the mast itself, which will relay it to another mast via a central hub and linked cards.

### Network centres

Most of the time, masts will be too far apart to communicate directly. A line of masts to two destinations will not work either due to the limit of packets dropping after five relays.

For this, masts will send (not relay) the packet to the destination (contained in the packet information) through the network centre. Network centres essentially act as "super-masts", connecting masts. They can also connect to eachother, through relays containing linked cards.

## Load distribution

It is essential for any network to efficiently manage load.

Masts will send back an ACK when they can. If the mast does not send an ACK, this typically means the mast is overloaded. The program will therefore send another packet after 5 seconds before timing out. This will also happen between masts and network centres.

The ability to have mutliple masts serve a region will eventually be added.
