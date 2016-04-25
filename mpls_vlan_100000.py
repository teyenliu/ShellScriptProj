"""Simple MPLS VLAN swap logic using OpenFlow Protocol v1.3.2"""

from ryu.base.app_manager import RyuApp
from ryu.controller.ofp_event import EventOFPSwitchFeatures
from ryu.controller.ofp_event import EventOFPPacketIn
from ryu.controller.handler import set_ev_cls
from ryu.controller.handler import CONFIG_DISPATCHER
from ryu.controller.handler import MAIN_DISPATCHER
from ryu.ofproto.ofproto_v1_2 import OFPG_ANY
from ryu.ofproto.ofproto_v1_3 import OFP_VERSION
from ryu.lib.mac import haddr_to_bin

class L2Switch(RyuApp):
    OFP_VERSIONS = [OFP_VERSION]

    def __init__(self, *args, **kwargs):
        super(L2Switch, self).__init__(*args, **kwargs)

    @set_ev_cls(EventOFPSwitchFeatures, CONFIG_DISPATCHER)
    def switch_features_handler(self, ev):
        """Handle switch features reply to install flow entries."""
        datapath = ev.msg.datapath
        print 'installing sample flow'
#        [self.install_sample2(datapath, n) for n in [0]]
        [self.install_sample(datapath, n) for n in [0]]

    def create_match(self, parser, fields):
        """Create OFP match struct from the list of fields."""
        match = parser.OFPMatch()
        for (field, value) in fields.iteritems():
            match.append_field(field, value)
        return match

    def create_flow_mod(self, datapath, priority,
                        table_id, match, instructions):
        """Create OFP flow mod message."""
        ofproto = datapath.ofproto
        flow_mod = datapath.ofproto_parser.OFPFlowMod(datapath, 0, 0, table_id,
                                                      ofproto.OFPFC_ADD, 0, 0,
                                                      priority,
                                                      ofproto.OFPCML_NO_BUFFER,
                                                      ofproto.OFPP_ANY,
                                                      OFPG_ANY, 0,
                                                      match, instructions)
        return flow_mod


    def create_meter_mod(self, datapath, command, flags_, meter_id, bands):
        ofproto = datapath.ofproto
        ofp_parser = datapath.ofproto_parser
        meter_mod = ofp_parser.OFPMeterMod(datapath, command, flags_,
                                           meter_id, bands)
        return meter_mod

    def install_sample(self, datapath, table_id):
        """Create and install sample flow entries."""
        parser = datapath.ofproto_parser
        ofproto = datapath.ofproto
        # Incoming port 1.
        in_port = 1;
        # Incoming Ethernet destination
        eth_dst = '\x00' + '\x00' + '\x00' + '\x00' + '\x00' + '\x00'
        for i in range(100000):
            match = self.create_match(parser,
                                      {ofproto.OXM_OF_IN_PORT: in_port,
                                       ofproto.OXM_OF_ETH_DST: eth_dst,
                                       ofproto.OXM_OF_ETH_TYPE: 0x8847,
                                       ofproto.OXM_OF_MPLS_LABEL: i})
            popmpls = parser.OFPActionPopMpls(0x0800)
            decttl = parser.OFPActionDecNwTtl()
            pushvlan = parser.OFPActionPushVlan(0x8100)
            setvlanid = parser.OFPActionSetField(vlan_vid=1)
            setethsrc = parser.OFPActionSetField(eth_src='00:00:00:00:00:00')
            setethdst = parser.OFPActionSetField(eth_dst='00:00:00:00:00:00')
            # Output to port 2.
            output = parser.OFPActionOutput(2, 0)
            write = parser.OFPInstructionActions(ofproto.OFPIT_APPLY_ACTIONS,
                                                 [popmpls, decttl, pushvlan,
                                                  setvlanid, setethsrc,
                                                  setethdst, output])
            instructions = [write]
            flow_mod = self.create_flow_mod(datapath, 100, table_id,
                                            match, instructions)
            datapath.send_msg(flow_mod)

        # Exist OFPMeterMod.
        if hasattr(parser, "OFPMeterMod"):
            band = parser.OFPMeterBandDrop(rate=10, burst_size=1)

            meter_mod = self.create_meter_mod(datapath,
                                              ofproto.OFPMC_ADD,
                                              ofproto.OFPMF_PKTPS,
                                              100,
                                              [band])
            print "send {s}".format(s = self.format_meter_mod(meter_mod))
            datapath.send_msg(meter_mod)

    def format_meter_mod(self, meter_mod):
        """meter_mod.__str__ is buggy."""
        return ("METER_MOD (command:{a}, flags_:{b}, "\
                    + "meter_id:{c}, bands:{d})")\
            .format(a = meter_mod.command,
                    b = meter_mod.flags,
                    c = meter_mod.meter_id,
                    d = meter_mod.bands)

    def install_sample2(self, datapath, table_id):
        """Create and install sample flow entries."""
        parser = datapath.ofproto_parser
        ofproto = datapath.ofproto
        # Incoming port 1.
        in_port = 1;
        # Incoming Ethernet source 
        eth_src = '\x01' + '\x02' + '\x03' + '\x0a' + '\x0b' + '\x0c'
        match = self.create_match(parser,
                                  {ofproto.OXM_OF_IN_PORT: in_port,
                                   ofproto.OXM_OF_ETH_SRC: eth_src})
        output = parser.OFPActionOutput(2, 0)
        write = parser.OFPInstructionActions(ofproto.OFPIT_WRITE_ACTIONS,
                                             [output])
        instructions = [write]
        flow_mod = self.create_flow_mod(datapath, 101, table_id,
                                        match, instructions)
        datapath.send_msg(flow_mod)

    @set_ev_cls(EventOFPPacketIn, MAIN_DISPATCHER)
    def _packet_in_handler(self, ev):
        """Handle packet_in events."""
        msg = ev.msg
        datapath = msg.datapath
        ofproto = datapath.ofproto
        table_id = msg.table_id
        fields = msg.match.fields

        # Extract fields
        for f in fields:
            if f.header == ofproto.OXM_OF_IN_PORT:
                in_port = f.value
            elif f.header == ofproto.OXM_OF_ETH_SRC:
                eth_src = f.value
            elif f.header == ofproto.OXM_OF_ETH_DST:
                eth_dst = f.value

        # Install flow entries
        if table_id == 0:
            print "installing new source mac received from port", in_port
            self.install_src_entry(datapath, in_port, eth_src)
            self.install_dst_entry(datapath, in_port, eth_src)

        # Flood
        self.flood(datapath, msg.data)

    def install_src_entry(self, datapath, in_port, eth_src):
        """Install flow entry matching on eth_src in table 0."""
        parser = datapath.ofproto_parser
        ofproto = datapath.ofproto
        match = self.create_match(parser,
                                  {ofproto.OXM_OF_IN_PORT: in_port,
                                   ofproto.OXM_OF_ETH_SRC: eth_src})
        goto = parser.OFPInstructionGotoTable(1)
        print 'install_src_entry'
        flow_mod = self.create_flow_mod(datapath, 123, 0, match, [goto])
        datapath.send_msg(flow_mod)

    def install_dst_entry(self, datapath, in_port, eth_src):
        """Install flow entry matching on eth_dst in table 1."""
        parser = datapath.ofproto_parser
        ofproto = datapath.ofproto
        match = self.create_match(parser, {ofproto.OXM_OF_ETH_DST: eth_src})
        output = parser.OFPActionOutput(in_port, ofproto.OFPCML_NO_BUFFER)
        write = parser.OFPInstructionActions(ofproto.OFPIT_WRITE_ACTIONS,
                                             [output])
        print 'install_dst_entry'
        flow_mod = self.create_flow_mod(datapath, 123, 1, match, [write])
        datapath.send_msg(flow_mod)

    def flood(self, datapath, data):
        """Send a packet_out with output to all ports."""
        parser = datapath.ofproto_parser
        ofproto = datapath.ofproto
        output_all = parser.OFPActionOutput(ofproto.OFPP_ALL,
                                            ofproto.OFPCML_NO_BUFFER)
        packet_out = parser.OFPPacketOut(datapath, 0xffffffff,
                                         ofproto.OFPP_CONTROLLER,
                                         [output_all], data)
        datapath.send_msg(packet_out)
