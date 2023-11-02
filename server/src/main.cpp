#include "observers.h"

#include <rapidjson/document.h>
#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>
#include <webrtc/api/peerconnectioninterface.h>
#include <webrtc/rtc_base/physicalsocketserver.h>
#include <webrtc/rtc_base/ssladapter.h>
#include <webrtc/rtc_base/thread.h>

#include <websocketpp/config/asio_no_tls.hpp>
#include <websocketpp/server.hpp>

#include <iostream>
#include <thread>
#include <memory>
#include <functional>

using namespace std;
using namespace websocketpp;
using namespace rapidjson;

using WebSocketServer = server<config::asio>;
using message_ptr = WebSocketServer::message_ptr;

WebSocketServer ws_server;
rtc::scoped_refptr<webrtc::PeerConnectionFactoryInterface> peer_connection_factory;
rtc::PhysicalSocketServer socket_server;
thread webrtc_thread;
connection_hdl websocket_connection_handler;
rtc::scoped_refptr<webrtc::PeerConnectionInterface> peer_connection;
rtc::scoped_refptr<webrtc::DataChannelInterface> data_channel;
PeerConnectionObserver peer_connection_observer(OnDataChannelCreated, OnIceCandidate);
DataChannelObserver data_channel_observer(OnDataChannelMessage);
CreateSessionDescriptionObserver create_session_description_observer(OnAnswerCreated);
SetSessionDescriptionObserver set_session_description_observer;

void OnDataChannelCreated(webrtc::DataChannelInterface* channel) {
  data_channel = channel;
  data_channel->RegisterObserver(&data_channel_observer);
}

void OnIceCandidate(const webrtc::IceCandidateInterface* candidate) {
  auto candidate_str = string{};
  candidate->ToString(&candidate_str);
  Document message_object;
  message_object.SetObject();
  message_object.AddMember("type", "candidate", message_object.GetAllocator());
  auto candidate_value = StringRef(candidate_str.c_str());
  auto sdp_mid_value = StringRef(candidate->sdp_mid().c_str());
  auto message_payload = Value{};
  message_payload.SetObject();
  message_payload.AddMember("candidate", candidate_value, message_object.GetAllocator());
  message_payload.AddMember("sdpMid", sdp_mid_value, message_object.GetAllocator());
  message_payload.AddMember("sdpMLineIndex", candidate->sdp_mline_index(), message_object.GetAllocator());
  message_object.AddMember("payload", message_payload, message_object.GetAllocator());
  auto strbuf = StringBuffer{};
  auto writer = Writer<StringBuffer>{strbuf};
  message_object.Accept(writer);
  auto payload = strbuf.GetString();
  ws_server.send(websocket_connection_handler, payload, frame::opcode::value::text);
}

void OnDataChannelMessage(const webrtc::DataBuffer& buffer) {
  data_channel->Send(buffer);
}

void OnAnswerCreated(webrtc::SessionDescriptionInterface* desc) {
  peer_connection->SetLocalDescription(&set_session_description_observer, desc);
  auto offer_string = string{};
  desc->ToString(&offer_string);
  auto message_object = Document{};
  message_object.SetObject();
  message_object.AddMember("type", "answer", message_object.GetAllocator());
  auto sdp_value = StringRef(offer_string.c_str());
  auto message_payload = Value{};
  message_payload.SetObject();
  message_payload.AddMember("type", "answer", message_object.GetAllocator());
  message_payload.AddMember("sdp", sdp_value, message_object.GetAllocator());
  message_object.AddMember("payload", message_payload, message_object.GetAllocator());
  auto strbuf = StringBuffer{};
  auto writer = Writer<StringBuffer>{strbuf};
  message_object.Accept(writer);
  auto payload = strbuf.GetString();
  ws_server.send(websocket_connection_handler, payload, frame::opcode::value::text);
}

void OnWebSocketMessage(WebSocketServer* s, connection_hdl hdl, message_ptr msg) {
  websocket_connection_handler = hdl;
  auto message_object = Document{};
  message_object.Parse(msg->get_payload().c_str());
  auto type = string{message_object["type"].GetString()};
  if (type == "ping") {
    auto id = msg->get_payload();
    ws_server.send(websocket_connection_handler, id, frame::opcode::value::text);
  } else if (type == "offer") {
    auto sdp = string{message_object["payload"]["sdp"].GetString()};
    auto configuration = webrtc::PeerConnectionInterface::RTCConfiguration{};
    auto ice_server = webrtc::PeerConnectionInterface::IceServer{};
    ice_server.uri = "stun:stun.l.google.com:19302";
    configuration.servers.push_back(ice_server);
    peer_connection = peer_connection_factory->CreatePeerConnection(configuration, nullptr, nullptr, &peer_connection_observer);
    auto data_channel_config = webrtc::DataChannelInit{};
    data_channel_config.ordered = false;
    data_channel_config.maxRetransmits = 0;
    data_channel = peer_connection->CreateDataChannel("dc", &data_channel_config);
    data_channel->RegisterObserver(&data_channel_observer);
    auto error = webrtc::SdpParseError{};
    auto session_description = unique_ptr<webrtc::SessionDescriptionInterface>{webrtc::CreateSessionDescription("offer", sdp, &error)};
    peer_connection->SetRemoteDescription(&set_session_description_observer, session_description.release());
    peer_connection->CreateAnswer(&create_session_description_observer, nullptr);
  } else if (type == "candidate") {
    auto candidate = string{message_object["payload"]["candidate"].GetString()};
    auto sdp_mline_index = message_object["payload"]["sdpMLineIndex"].GetInt();
    auto sdp_mid = string{message_object["payload"]["sdpMid"].GetString()};
    auto error = webrtc::SdpParseError{};
    auto candidate_object = unique_ptr<webrtc::IceCandidateInterface>{webrtc::CreateIceCandidate(sdp_mid, sdp_mline_index, candidate, &error)};
    peer_connection->AddIceCandidate(candidate_object.get());
  } else {
    cout << "Unrecognized WebSocket message type." << endl;
  }
}

void SignalThreadEntry() {
  rtc::InitializeSSL();
  peer_connection_factory = webrtc::CreatePeerConnectionFactory();
  auto* signaling_thread = rtc::Thread::Current();
  signaling_thread->set_socketserver(&socket_server);
  signaling_thread->Run();
  signaling_thread->set_socketserver(nullptr);
}

int main() {
  webrtc_thread = thread{SignalThreadEntry};
  ws_server.set_message_handler(bind(OnWebSocketMessage, &ws_server, placeholders::_1, placeholders::_2));
  ws_server.init_asio();
  ws_server.clear_access_channels(log::alevel::all);
  ws_server.set_reuse_addr(true);
  ws_server.listen(8080);
  ws_server.start_accept();
  ws_server.run();
  rtc::CleanupSSL();
}
