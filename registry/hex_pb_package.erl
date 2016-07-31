%% -*- coding: utf-8 -*-
%% Automatically generated, do not edit
%% Generated by gpb_compile version 3.24.3
-module(hex_pb_package).

-export([encode_msg/2, encode_msg/3]).
-export([encode/1]). %% epb compatibility
-export([decode_msg/2, decode_msg/3]).
-export([merge_msgs/3, merge_msgs/4]).
-export([decode/2]). %% epb compatibility
-export([verify_msg/2, verify_msg/3]).
-export([get_msg_defs/0]).
-export([get_msg_names/0]).
-export([get_enum_names/0]).
-export([find_msg_def/1, fetch_msg_def/1]).
-export([find_enum_def/1, fetch_enum_def/1]).
-export([enum_symbol_by_value/2, enum_value_by_symbol/2]).
-export([enum_symbol_by_value_YankReason/1, enum_value_by_symbol_YankReason/1]).
-export([get_service_names/0]).
-export([get_service_def/1]).
-export([get_rpc_names/1]).
-export([find_rpc_def/2, fetch_rpc_def/2]).
-export([get_package_name/0]).
-export([gpb_version_as_string/0, gpb_version_as_list/0]).



-spec encode_msg(_,atom()) -> binary().
encode_msg(Msg, MsgName) ->
    encode_msg(Msg, MsgName, []).


-spec encode_msg(_,atom(), list()) -> binary().
encode_msg(Msg, MsgName, Opts) ->
    verify_msg(Msg, MsgName, Opts),
    TrUserData = proplists:get_value(user_data, Opts),
    case MsgName of
      'YankStatus' -> e_msg_YankStatus(Msg, TrUserData);
      'Dependency' -> e_msg_Dependency(Msg, TrUserData);
      'Release' -> e_msg_Release(Msg, TrUserData);
      'Package' -> e_msg_Package(Msg, TrUserData)
    end.


%% epb compatibility
encode(_Msg) ->
    erlang:error({gpb_error,
		  epb_compat_not_possible_with_maps}).


e_msg_YankStatus(Msg, TrUserData) ->
    e_msg_YankStatus(Msg, <<>>, TrUserData).


e_msg_YankStatus(#{reason := F1} = M, Bin,
		 TrUserData) ->
    B1 = begin
	   TrF1 = id(F1, TrUserData),
	   e_enum_YankReason(TrF1, <<Bin/binary, 8>>)
	 end,
    case M of
      #{message := F2} ->
	  TrF2 = id(F2, TrUserData),
	  e_type_string(TrF2, <<B1/binary, 18>>);
      _ -> B1
    end.

e_msg_Dependency(Msg, TrUserData) ->
    e_msg_Dependency(Msg, <<>>, TrUserData).


e_msg_Dependency(#{package := F1, requirement := F2} =
		     M,
		 Bin, TrUserData) ->
    B1 = begin
	   TrF1 = id(F1, TrUserData),
	   e_type_string(TrF1, <<Bin/binary, 10>>)
	 end,
    B2 = begin
	   TrF2 = id(F2, TrUserData),
	   e_type_string(TrF2, <<B1/binary, 18>>)
	 end,
    B3 = case M of
	   #{optional := F3} ->
	       TrF3 = id(F3, TrUserData),
	       e_type_bool(TrF3, <<B2/binary, 24>>);
	   _ -> B2
	 end,
    case M of
      #{app := F4} ->
	  TrF4 = id(F4, TrUserData),
	  e_type_string(TrF4, <<B3/binary, 34>>);
      _ -> B3
    end.

e_msg_Release(Msg, TrUserData) ->
    e_msg_Release(Msg, <<>>, TrUserData).


e_msg_Release(#{version := F1, checksum := F2,
		dependencies := F3} =
		  M,
	      Bin, TrUserData) ->
    B1 = begin
	   TrF1 = id(F1, TrUserData),
	   e_type_string(TrF1, <<Bin/binary, 10>>)
	 end,
    B2 = begin
	   TrF2 = id(F2, TrUserData),
	   e_type_bytes(TrF2, <<B1/binary, 18>>)
	 end,
    B3 = begin
	   TrF3 = id(F3, TrUserData),
	   if TrF3 == [] -> B2;
	      true ->
		  e_field_Release_dependencies(TrF3, B2, TrUserData)
	   end
	 end,
    case M of
      #{yanked := F4} ->
	  TrF4 = id(F4, TrUserData),
	  e_mfield_Release_yanked(TrF4, <<B3/binary, 34>>,
				  TrUserData);
      _ -> B3
    end.

e_msg_Package(Msg, TrUserData) ->
    e_msg_Package(Msg, <<>>, TrUserData).


e_msg_Package(#{releases := F1}, Bin, TrUserData) ->
    begin
      TrF1 = id(F1, TrUserData),
      if TrF1 == [] -> Bin;
	 true -> e_field_Package_releases(TrF1, Bin, TrUserData)
      end
    end.

e_mfield_Release_dependencies(Msg, Bin, TrUserData) ->
    SubBin = e_msg_Dependency(Msg, <<>>, TrUserData),
    Bin2 = e_varint(byte_size(SubBin), Bin),
    <<Bin2/binary, SubBin/binary>>.

e_field_Release_dependencies([Elem | Rest], Bin,
			     TrUserData) ->
    Bin2 = <<Bin/binary, 26>>,
    Bin3 = e_mfield_Release_dependencies(id(Elem,
					    TrUserData),
					 Bin2, TrUserData),
    e_field_Release_dependencies(Rest, Bin3, TrUserData);
e_field_Release_dependencies([], Bin, _TrUserData) ->
    Bin.

e_mfield_Release_yanked(Msg, Bin, TrUserData) ->
    SubBin = e_msg_YankStatus(Msg, <<>>, TrUserData),
    Bin2 = e_varint(byte_size(SubBin), Bin),
    <<Bin2/binary, SubBin/binary>>.

e_mfield_Package_releases(Msg, Bin, TrUserData) ->
    SubBin = e_msg_Release(Msg, <<>>, TrUserData),
    Bin2 = e_varint(byte_size(SubBin), Bin),
    <<Bin2/binary, SubBin/binary>>.

e_field_Package_releases([Elem | Rest], Bin,
			 TrUserData) ->
    Bin2 = <<Bin/binary, 10>>,
    Bin3 = e_mfield_Package_releases(id(Elem, TrUserData),
				     Bin2, TrUserData),
    e_field_Package_releases(Rest, Bin3, TrUserData);
e_field_Package_releases([], Bin, _TrUserData) -> Bin.



e_enum_YankReason('YANKED_OTHER', Bin) ->
    <<Bin/binary, 0>>;
e_enum_YankReason('YANKED_INVALID', Bin) ->
    <<Bin/binary, 1>>;
e_enum_YankReason('YANKED_SECURITY', Bin) ->
    <<Bin/binary, 2>>;
e_enum_YankReason('YANKED_DEPRECATED', Bin) ->
    <<Bin/binary, 3>>;
e_enum_YankReason('YANKED_RENAMED', Bin) ->
    <<Bin/binary, 4>>;
e_enum_YankReason(V, Bin) -> e_varint(V, Bin).

e_type_bool(true, Bin) -> <<Bin/binary, 1>>;
e_type_bool(false, Bin) -> <<Bin/binary, 0>>;
e_type_bool(1, Bin) -> <<Bin/binary, 1>>;
e_type_bool(0, Bin) -> <<Bin/binary, 0>>.

e_type_string(S, Bin) ->
    Utf8 = unicode:characters_to_binary(S),
    Bin2 = e_varint(byte_size(Utf8), Bin),
    <<Bin2/binary, Utf8/binary>>.

e_type_bytes(Bytes, Bin) when is_binary(Bytes) ->
    Bin2 = e_varint(byte_size(Bytes), Bin),
    <<Bin2/binary, Bytes/binary>>;
e_type_bytes(Bytes, Bin) when is_list(Bytes) ->
    BytesBin = iolist_to_binary(Bytes),
    Bin2 = e_varint(byte_size(BytesBin), Bin),
    <<Bin2/binary, BytesBin/binary>>.

e_varint(N, Bin) when N =< 127 -> <<Bin/binary, N>>;
e_varint(N, Bin) ->
    Bin2 = <<Bin/binary, (N band 127 bor 128)>>,
    e_varint(N bsr 7, Bin2).



decode_msg(Bin, MsgName) when is_binary(Bin) ->
    decode_msg(Bin, MsgName, []).

decode_msg(Bin, MsgName, Opts) when is_binary(Bin) ->
    TrUserData = proplists:get_value(user_data, Opts),
    case MsgName of
      'YankStatus' -> d_msg_YankStatus(Bin, TrUserData);
      'Dependency' -> d_msg_Dependency(Bin, TrUserData);
      'Release' -> d_msg_Release(Bin, TrUserData);
      'Package' -> d_msg_Package(Bin, TrUserData)
    end.


%% epb compatibility
decode(MsgName, Bin)
    when is_atom(MsgName), is_binary(Bin) ->
    erlang:error({gpb_error,
		  epb_compat_not_possible_with_maps}).



d_msg_YankStatus(Bin, TrUserData) ->
    dfp_read_field_def_YankStatus(Bin, 0, 0,
				  id('$undef', TrUserData),
				  id('$undef', TrUserData), TrUserData).

dfp_read_field_def_YankStatus(<<8, Rest/binary>>, Z1,
			      Z2, F1, F2, TrUserData) ->
    d_field_YankStatus_reason(Rest, Z1, Z2, F1, F2,
			      TrUserData);
dfp_read_field_def_YankStatus(<<18, Rest/binary>>, Z1,
			      Z2, F1, F2, TrUserData) ->
    d_field_YankStatus_message(Rest, Z1, Z2, F1, F2,
			       TrUserData);
dfp_read_field_def_YankStatus(<<>>, 0, 0, F1, F2, _) ->
    S1 = #{reason => F1},
    if F2 == '$undef' -> S1;
       true -> S1#{message => F2}
    end;
dfp_read_field_def_YankStatus(Other, Z1, Z2, F1, F2,
			      TrUserData) ->
    dg_read_field_def_YankStatus(Other, Z1, Z2, F1, F2,
				 TrUserData).

dg_read_field_def_YankStatus(<<1:1, X:7, Rest/binary>>,
			     N, Acc, F1, F2, TrUserData)
    when N < 32 - 7 ->
    dg_read_field_def_YankStatus(Rest, N + 7, X bsl N + Acc,
				 F1, F2, TrUserData);
dg_read_field_def_YankStatus(<<0:1, X:7, Rest/binary>>,
			     N, Acc, F1, F2, TrUserData) ->
    Key = X bsl N + Acc,
    case Key of
      8 ->
	  d_field_YankStatus_reason(Rest, 0, 0, F1, F2,
				    TrUserData);
      18 ->
	  d_field_YankStatus_message(Rest, 0, 0, F1, F2,
				     TrUserData);
      _ ->
	  case Key band 7 of
	    0 ->
		skip_varint_YankStatus(Rest, 0, 0, F1, F2, TrUserData);
	    1 -> skip_64_YankStatus(Rest, 0, 0, F1, F2, TrUserData);
	    2 ->
		skip_length_delimited_YankStatus(Rest, 0, 0, F1, F2,
						 TrUserData);
	    5 -> skip_32_YankStatus(Rest, 0, 0, F1, F2, TrUserData)
	  end
    end;
dg_read_field_def_YankStatus(<<>>, 0, 0, F1, F2, _) ->
    S1 = #{reason => F1},
    if F2 == '$undef' -> S1;
       true -> S1#{message => F2}
    end.

d_field_YankStatus_reason(<<1:1, X:7, Rest/binary>>, N,
			  Acc, F1, F2, TrUserData)
    when N < 57 ->
    d_field_YankStatus_reason(Rest, N + 7, X bsl N + Acc,
			      F1, F2, TrUserData);
d_field_YankStatus_reason(<<0:1, X:7, Rest/binary>>, N,
			  Acc, _, F2, TrUserData) ->
    <<Tmp:32/signed-native>> = <<(X bsl N +
				    Acc):32/unsigned-native>>,
    NewFValue = d_enum_YankReason(Tmp),
    dfp_read_field_def_YankStatus(Rest, 0, 0, NewFValue, F2,
				  TrUserData).


d_field_YankStatus_message(<<1:1, X:7, Rest/binary>>, N,
			   Acc, F1, F2, TrUserData)
    when N < 57 ->
    d_field_YankStatus_message(Rest, N + 7, X bsl N + Acc,
			       F1, F2, TrUserData);
d_field_YankStatus_message(<<0:1, X:7, Rest/binary>>, N,
			   Acc, F1, _, TrUserData) ->
    Len = X bsl N + Acc,
    <<Bytes:Len/binary, Rest2/binary>> = Rest,
    NewFValue = binary:copy(Bytes),
    dfp_read_field_def_YankStatus(Rest2, 0, 0, F1,
				  NewFValue, TrUserData).


skip_varint_YankStatus(<<1:1, _:7, Rest/binary>>, Z1,
		       Z2, F1, F2, TrUserData) ->
    skip_varint_YankStatus(Rest, Z1, Z2, F1, F2,
			   TrUserData);
skip_varint_YankStatus(<<0:1, _:7, Rest/binary>>, Z1,
		       Z2, F1, F2, TrUserData) ->
    dfp_read_field_def_YankStatus(Rest, Z1, Z2, F1, F2,
				  TrUserData).


skip_length_delimited_YankStatus(<<1:1, X:7,
				   Rest/binary>>,
				 N, Acc, F1, F2, TrUserData)
    when N < 57 ->
    skip_length_delimited_YankStatus(Rest, N + 7,
				     X bsl N + Acc, F1, F2, TrUserData);
skip_length_delimited_YankStatus(<<0:1, X:7,
				   Rest/binary>>,
				 N, Acc, F1, F2, TrUserData) ->
    Length = X bsl N + Acc,
    <<_:Length/binary, Rest2/binary>> = Rest,
    dfp_read_field_def_YankStatus(Rest2, 0, 0, F1, F2,
				  TrUserData).


skip_32_YankStatus(<<_:32, Rest/binary>>, Z1, Z2, F1,
		   F2, TrUserData) ->
    dfp_read_field_def_YankStatus(Rest, Z1, Z2, F1, F2,
				  TrUserData).


skip_64_YankStatus(<<_:64, Rest/binary>>, Z1, Z2, F1,
		   F2, TrUserData) ->
    dfp_read_field_def_YankStatus(Rest, Z1, Z2, F1, F2,
				  TrUserData).


d_msg_Dependency(Bin, TrUserData) ->
    dfp_read_field_def_Dependency(Bin, 0, 0,
				  id('$undef', TrUserData),
				  id('$undef', TrUserData),
				  id('$undef', TrUserData),
				  id('$undef', TrUserData), TrUserData).

dfp_read_field_def_Dependency(<<10, Rest/binary>>, Z1,
			      Z2, F1, F2, F3, F4, TrUserData) ->
    d_field_Dependency_package(Rest, Z1, Z2, F1, F2, F3, F4,
			       TrUserData);
dfp_read_field_def_Dependency(<<18, Rest/binary>>, Z1,
			      Z2, F1, F2, F3, F4, TrUserData) ->
    d_field_Dependency_requirement(Rest, Z1, Z2, F1, F2, F3,
				   F4, TrUserData);
dfp_read_field_def_Dependency(<<24, Rest/binary>>, Z1,
			      Z2, F1, F2, F3, F4, TrUserData) ->
    d_field_Dependency_optional(Rest, Z1, Z2, F1, F2, F3,
				F4, TrUserData);
dfp_read_field_def_Dependency(<<34, Rest/binary>>, Z1,
			      Z2, F1, F2, F3, F4, TrUserData) ->
    d_field_Dependency_app(Rest, Z1, Z2, F1, F2, F3, F4,
			   TrUserData);
dfp_read_field_def_Dependency(<<>>, 0, 0, F1, F2, F3,
			      F4, _) ->
    S1 = #{package => F1, requirement => F2},
    S2 = if F3 == '$undef' -> S1;
	    true -> S1#{optional => F3}
	 end,
    if F4 == '$undef' -> S2;
       true -> S2#{app => F4}
    end;
dfp_read_field_def_Dependency(Other, Z1, Z2, F1, F2, F3,
			      F4, TrUserData) ->
    dg_read_field_def_Dependency(Other, Z1, Z2, F1, F2, F3,
				 F4, TrUserData).

dg_read_field_def_Dependency(<<1:1, X:7, Rest/binary>>,
			     N, Acc, F1, F2, F3, F4, TrUserData)
    when N < 32 - 7 ->
    dg_read_field_def_Dependency(Rest, N + 7, X bsl N + Acc,
				 F1, F2, F3, F4, TrUserData);
dg_read_field_def_Dependency(<<0:1, X:7, Rest/binary>>,
			     N, Acc, F1, F2, F3, F4, TrUserData) ->
    Key = X bsl N + Acc,
    case Key of
      10 ->
	  d_field_Dependency_package(Rest, 0, 0, F1, F2, F3, F4,
				     TrUserData);
      18 ->
	  d_field_Dependency_requirement(Rest, 0, 0, F1, F2, F3,
					 F4, TrUserData);
      24 ->
	  d_field_Dependency_optional(Rest, 0, 0, F1, F2, F3, F4,
				      TrUserData);
      34 ->
	  d_field_Dependency_app(Rest, 0, 0, F1, F2, F3, F4,
				 TrUserData);
      _ ->
	  case Key band 7 of
	    0 ->
		skip_varint_Dependency(Rest, 0, 0, F1, F2, F3, F4,
				       TrUserData);
	    1 ->
		skip_64_Dependency(Rest, 0, 0, F1, F2, F3, F4,
				   TrUserData);
	    2 ->
		skip_length_delimited_Dependency(Rest, 0, 0, F1, F2, F3,
						 F4, TrUserData);
	    5 ->
		skip_32_Dependency(Rest, 0, 0, F1, F2, F3, F4,
				   TrUserData)
	  end
    end;
dg_read_field_def_Dependency(<<>>, 0, 0, F1, F2, F3, F4,
			     _) ->
    S1 = #{package => F1, requirement => F2},
    S2 = if F3 == '$undef' -> S1;
	    true -> S1#{optional => F3}
	 end,
    if F4 == '$undef' -> S2;
       true -> S2#{app => F4}
    end.

d_field_Dependency_package(<<1:1, X:7, Rest/binary>>, N,
			   Acc, F1, F2, F3, F4, TrUserData)
    when N < 57 ->
    d_field_Dependency_package(Rest, N + 7, X bsl N + Acc,
			       F1, F2, F3, F4, TrUserData);
d_field_Dependency_package(<<0:1, X:7, Rest/binary>>, N,
			   Acc, _, F2, F3, F4, TrUserData) ->
    Len = X bsl N + Acc,
    <<Bytes:Len/binary, Rest2/binary>> = Rest,
    NewFValue = binary:copy(Bytes),
    dfp_read_field_def_Dependency(Rest2, 0, 0, NewFValue,
				  F2, F3, F4, TrUserData).


d_field_Dependency_requirement(<<1:1, X:7,
				 Rest/binary>>,
			       N, Acc, F1, F2, F3, F4, TrUserData)
    when N < 57 ->
    d_field_Dependency_requirement(Rest, N + 7,
				   X bsl N + Acc, F1, F2, F3, F4, TrUserData);
d_field_Dependency_requirement(<<0:1, X:7,
				 Rest/binary>>,
			       N, Acc, F1, _, F3, F4, TrUserData) ->
    Len = X bsl N + Acc,
    <<Bytes:Len/binary, Rest2/binary>> = Rest,
    NewFValue = binary:copy(Bytes),
    dfp_read_field_def_Dependency(Rest2, 0, 0, F1,
				  NewFValue, F3, F4, TrUserData).


d_field_Dependency_optional(<<1:1, X:7, Rest/binary>>,
			    N, Acc, F1, F2, F3, F4, TrUserData)
    when N < 57 ->
    d_field_Dependency_optional(Rest, N + 7, X bsl N + Acc,
				F1, F2, F3, F4, TrUserData);
d_field_Dependency_optional(<<0:1, X:7, Rest/binary>>,
			    N, Acc, F1, F2, _, F4, TrUserData) ->
    NewFValue = X bsl N + Acc =/= 0,
    dfp_read_field_def_Dependency(Rest, 0, 0, F1, F2,
				  NewFValue, F4, TrUserData).


d_field_Dependency_app(<<1:1, X:7, Rest/binary>>, N,
		       Acc, F1, F2, F3, F4, TrUserData)
    when N < 57 ->
    d_field_Dependency_app(Rest, N + 7, X bsl N + Acc, F1,
			   F2, F3, F4, TrUserData);
d_field_Dependency_app(<<0:1, X:7, Rest/binary>>, N,
		       Acc, F1, F2, F3, _, TrUserData) ->
    Len = X bsl N + Acc,
    <<Bytes:Len/binary, Rest2/binary>> = Rest,
    NewFValue = binary:copy(Bytes),
    dfp_read_field_def_Dependency(Rest2, 0, 0, F1, F2, F3,
				  NewFValue, TrUserData).


skip_varint_Dependency(<<1:1, _:7, Rest/binary>>, Z1,
		       Z2, F1, F2, F3, F4, TrUserData) ->
    skip_varint_Dependency(Rest, Z1, Z2, F1, F2, F3, F4,
			   TrUserData);
skip_varint_Dependency(<<0:1, _:7, Rest/binary>>, Z1,
		       Z2, F1, F2, F3, F4, TrUserData) ->
    dfp_read_field_def_Dependency(Rest, Z1, Z2, F1, F2, F3,
				  F4, TrUserData).


skip_length_delimited_Dependency(<<1:1, X:7,
				   Rest/binary>>,
				 N, Acc, F1, F2, F3, F4, TrUserData)
    when N < 57 ->
    skip_length_delimited_Dependency(Rest, N + 7,
				     X bsl N + Acc, F1, F2, F3, F4, TrUserData);
skip_length_delimited_Dependency(<<0:1, X:7,
				   Rest/binary>>,
				 N, Acc, F1, F2, F3, F4, TrUserData) ->
    Length = X bsl N + Acc,
    <<_:Length/binary, Rest2/binary>> = Rest,
    dfp_read_field_def_Dependency(Rest2, 0, 0, F1, F2, F3,
				  F4, TrUserData).


skip_32_Dependency(<<_:32, Rest/binary>>, Z1, Z2, F1,
		   F2, F3, F4, TrUserData) ->
    dfp_read_field_def_Dependency(Rest, Z1, Z2, F1, F2, F3,
				  F4, TrUserData).


skip_64_Dependency(<<_:64, Rest/binary>>, Z1, Z2, F1,
		   F2, F3, F4, TrUserData) ->
    dfp_read_field_def_Dependency(Rest, Z1, Z2, F1, F2, F3,
				  F4, TrUserData).


d_msg_Release(Bin, TrUserData) ->
    dfp_read_field_def_Release(Bin, 0, 0,
			       id('$undef', TrUserData),
			       id('$undef', TrUserData), id([], TrUserData),
			       id('$undef', TrUserData), TrUserData).

dfp_read_field_def_Release(<<10, Rest/binary>>, Z1, Z2,
			   F1, F2, F3, F4, TrUserData) ->
    d_field_Release_version(Rest, Z1, Z2, F1, F2, F3, F4,
			    TrUserData);
dfp_read_field_def_Release(<<18, Rest/binary>>, Z1, Z2,
			   F1, F2, F3, F4, TrUserData) ->
    d_field_Release_checksum(Rest, Z1, Z2, F1, F2, F3, F4,
			     TrUserData);
dfp_read_field_def_Release(<<26, Rest/binary>>, Z1, Z2,
			   F1, F2, F3, F4, TrUserData) ->
    d_field_Release_dependencies(Rest, Z1, Z2, F1, F2, F3,
				 F4, TrUserData);
dfp_read_field_def_Release(<<34, Rest/binary>>, Z1, Z2,
			   F1, F2, F3, F4, TrUserData) ->
    d_field_Release_yanked(Rest, Z1, Z2, F1, F2, F3, F4,
			   TrUserData);
dfp_read_field_def_Release(<<>>, 0, 0, F1, F2, F3, F4,
			   TrUserData) ->
    S1 = #{version => F1, checksum => F2,
	   dependencies => lists_reverse(F3, TrUserData)},
    if F4 == '$undef' -> S1;
       true -> S1#{yanked => F4}
    end;
dfp_read_field_def_Release(Other, Z1, Z2, F1, F2, F3,
			   F4, TrUserData) ->
    dg_read_field_def_Release(Other, Z1, Z2, F1, F2, F3, F4,
			      TrUserData).

dg_read_field_def_Release(<<1:1, X:7, Rest/binary>>, N,
			  Acc, F1, F2, F3, F4, TrUserData)
    when N < 32 - 7 ->
    dg_read_field_def_Release(Rest, N + 7, X bsl N + Acc,
			      F1, F2, F3, F4, TrUserData);
dg_read_field_def_Release(<<0:1, X:7, Rest/binary>>, N,
			  Acc, F1, F2, F3, F4, TrUserData) ->
    Key = X bsl N + Acc,
    case Key of
      10 ->
	  d_field_Release_version(Rest, 0, 0, F1, F2, F3, F4,
				  TrUserData);
      18 ->
	  d_field_Release_checksum(Rest, 0, 0, F1, F2, F3, F4,
				   TrUserData);
      26 ->
	  d_field_Release_dependencies(Rest, 0, 0, F1, F2, F3, F4,
				       TrUserData);
      34 ->
	  d_field_Release_yanked(Rest, 0, 0, F1, F2, F3, F4,
				 TrUserData);
      _ ->
	  case Key band 7 of
	    0 ->
		skip_varint_Release(Rest, 0, 0, F1, F2, F3, F4,
				    TrUserData);
	    1 ->
		skip_64_Release(Rest, 0, 0, F1, F2, F3, F4, TrUserData);
	    2 ->
		skip_length_delimited_Release(Rest, 0, 0, F1, F2, F3,
					      F4, TrUserData);
	    5 ->
		skip_32_Release(Rest, 0, 0, F1, F2, F3, F4, TrUserData)
	  end
    end;
dg_read_field_def_Release(<<>>, 0, 0, F1, F2, F3, F4,
			  TrUserData) ->
    S1 = #{version => F1, checksum => F2,
	   dependencies => lists_reverse(F3, TrUserData)},
    if F4 == '$undef' -> S1;
       true -> S1#{yanked => F4}
    end.

d_field_Release_version(<<1:1, X:7, Rest/binary>>, N,
			Acc, F1, F2, F3, F4, TrUserData)
    when N < 57 ->
    d_field_Release_version(Rest, N + 7, X bsl N + Acc, F1,
			    F2, F3, F4, TrUserData);
d_field_Release_version(<<0:1, X:7, Rest/binary>>, N,
			Acc, _, F2, F3, F4, TrUserData) ->
    Len = X bsl N + Acc,
    <<Bytes:Len/binary, Rest2/binary>> = Rest,
    NewFValue = binary:copy(Bytes),
    dfp_read_field_def_Release(Rest2, 0, 0, NewFValue, F2,
			       F3, F4, TrUserData).


d_field_Release_checksum(<<1:1, X:7, Rest/binary>>, N,
			 Acc, F1, F2, F3, F4, TrUserData)
    when N < 57 ->
    d_field_Release_checksum(Rest, N + 7, X bsl N + Acc, F1,
			     F2, F3, F4, TrUserData);
d_field_Release_checksum(<<0:1, X:7, Rest/binary>>, N,
			 Acc, F1, _, F3, F4, TrUserData) ->
    Len = X bsl N + Acc,
    <<Bytes:Len/binary, Rest2/binary>> = Rest,
    NewFValue = binary:copy(Bytes),
    dfp_read_field_def_Release(Rest2, 0, 0, F1, NewFValue,
			       F3, F4, TrUserData).


d_field_Release_dependencies(<<1:1, X:7, Rest/binary>>,
			     N, Acc, F1, F2, F3, F4, TrUserData)
    when N < 57 ->
    d_field_Release_dependencies(Rest, N + 7, X bsl N + Acc,
				 F1, F2, F3, F4, TrUserData);
d_field_Release_dependencies(<<0:1, X:7, Rest/binary>>,
			     N, Acc, F1, F2, F3, F4, TrUserData) ->
    Len = X bsl N + Acc,
    <<Bs:Len/binary, Rest2/binary>> = Rest,
    NewFValue = id(d_msg_Dependency(Bs, TrUserData),
		   TrUserData),
    dfp_read_field_def_Release(Rest2, 0, 0, F1, F2,
			       cons(NewFValue, F3, TrUserData), F4, TrUserData).


d_field_Release_yanked(<<1:1, X:7, Rest/binary>>, N,
		       Acc, F1, F2, F3, F4, TrUserData)
    when N < 57 ->
    d_field_Release_yanked(Rest, N + 7, X bsl N + Acc, F1,
			   F2, F3, F4, TrUserData);
d_field_Release_yanked(<<0:1, X:7, Rest/binary>>, N,
		       Acc, F1, F2, F3, F4, TrUserData) ->
    Len = X bsl N + Acc,
    <<Bs:Len/binary, Rest2/binary>> = Rest,
    NewFValue = id(d_msg_YankStatus(Bs, TrUserData),
		   TrUserData),
    dfp_read_field_def_Release(Rest2, 0, 0, F1, F2, F3,
			       if F4 =:= '$undef' -> NewFValue;
				  true ->
				      merge_msg_YankStatus(F4, NewFValue,
							   TrUserData)
			       end,
			       TrUserData).


skip_varint_Release(<<1:1, _:7, Rest/binary>>, Z1, Z2,
		    F1, F2, F3, F4, TrUserData) ->
    skip_varint_Release(Rest, Z1, Z2, F1, F2, F3, F4,
			TrUserData);
skip_varint_Release(<<0:1, _:7, Rest/binary>>, Z1, Z2,
		    F1, F2, F3, F4, TrUserData) ->
    dfp_read_field_def_Release(Rest, Z1, Z2, F1, F2, F3, F4,
			       TrUserData).


skip_length_delimited_Release(<<1:1, X:7, Rest/binary>>,
			      N, Acc, F1, F2, F3, F4, TrUserData)
    when N < 57 ->
    skip_length_delimited_Release(Rest, N + 7,
				  X bsl N + Acc, F1, F2, F3, F4, TrUserData);
skip_length_delimited_Release(<<0:1, X:7, Rest/binary>>,
			      N, Acc, F1, F2, F3, F4, TrUserData) ->
    Length = X bsl N + Acc,
    <<_:Length/binary, Rest2/binary>> = Rest,
    dfp_read_field_def_Release(Rest2, 0, 0, F1, F2, F3, F4,
			       TrUserData).


skip_32_Release(<<_:32, Rest/binary>>, Z1, Z2, F1, F2,
		F3, F4, TrUserData) ->
    dfp_read_field_def_Release(Rest, Z1, Z2, F1, F2, F3, F4,
			       TrUserData).


skip_64_Release(<<_:64, Rest/binary>>, Z1, Z2, F1, F2,
		F3, F4, TrUserData) ->
    dfp_read_field_def_Release(Rest, Z1, Z2, F1, F2, F3, F4,
			       TrUserData).


d_msg_Package(Bin, TrUserData) ->
    dfp_read_field_def_Package(Bin, 0, 0,
			       id([], TrUserData), TrUserData).

dfp_read_field_def_Package(<<10, Rest/binary>>, Z1, Z2,
			   F1, TrUserData) ->
    d_field_Package_releases(Rest, Z1, Z2, F1, TrUserData);
dfp_read_field_def_Package(<<>>, 0, 0, F1,
			   TrUserData) ->
    #{releases => lists_reverse(F1, TrUserData)};
dfp_read_field_def_Package(Other, Z1, Z2, F1,
			   TrUserData) ->
    dg_read_field_def_Package(Other, Z1, Z2, F1,
			      TrUserData).

dg_read_field_def_Package(<<1:1, X:7, Rest/binary>>, N,
			  Acc, F1, TrUserData)
    when N < 32 - 7 ->
    dg_read_field_def_Package(Rest, N + 7, X bsl N + Acc,
			      F1, TrUserData);
dg_read_field_def_Package(<<0:1, X:7, Rest/binary>>, N,
			  Acc, F1, TrUserData) ->
    Key = X bsl N + Acc,
    case Key of
      10 ->
	  d_field_Package_releases(Rest, 0, 0, F1, TrUserData);
      _ ->
	  case Key band 7 of
	    0 -> skip_varint_Package(Rest, 0, 0, F1, TrUserData);
	    1 -> skip_64_Package(Rest, 0, 0, F1, TrUserData);
	    2 ->
		skip_length_delimited_Package(Rest, 0, 0, F1,
					      TrUserData);
	    5 -> skip_32_Package(Rest, 0, 0, F1, TrUserData)
	  end
    end;
dg_read_field_def_Package(<<>>, 0, 0, F1, TrUserData) ->
    #{releases => lists_reverse(F1, TrUserData)}.

d_field_Package_releases(<<1:1, X:7, Rest/binary>>, N,
			 Acc, F1, TrUserData)
    when N < 57 ->
    d_field_Package_releases(Rest, N + 7, X bsl N + Acc, F1,
			     TrUserData);
d_field_Package_releases(<<0:1, X:7, Rest/binary>>, N,
			 Acc, F1, TrUserData) ->
    Len = X bsl N + Acc,
    <<Bs:Len/binary, Rest2/binary>> = Rest,
    NewFValue = id(d_msg_Release(Bs, TrUserData),
		   TrUserData),
    dfp_read_field_def_Package(Rest2, 0, 0,
			       cons(NewFValue, F1, TrUserData), TrUserData).


skip_varint_Package(<<1:1, _:7, Rest/binary>>, Z1, Z2,
		    F1, TrUserData) ->
    skip_varint_Package(Rest, Z1, Z2, F1, TrUserData);
skip_varint_Package(<<0:1, _:7, Rest/binary>>, Z1, Z2,
		    F1, TrUserData) ->
    dfp_read_field_def_Package(Rest, Z1, Z2, F1,
			       TrUserData).


skip_length_delimited_Package(<<1:1, X:7, Rest/binary>>,
			      N, Acc, F1, TrUserData)
    when N < 57 ->
    skip_length_delimited_Package(Rest, N + 7,
				  X bsl N + Acc, F1, TrUserData);
skip_length_delimited_Package(<<0:1, X:7, Rest/binary>>,
			      N, Acc, F1, TrUserData) ->
    Length = X bsl N + Acc,
    <<_:Length/binary, Rest2/binary>> = Rest,
    dfp_read_field_def_Package(Rest2, 0, 0, F1, TrUserData).


skip_32_Package(<<_:32, Rest/binary>>, Z1, Z2, F1,
		TrUserData) ->
    dfp_read_field_def_Package(Rest, Z1, Z2, F1,
			       TrUserData).


skip_64_Package(<<_:64, Rest/binary>>, Z1, Z2, F1,
		TrUserData) ->
    dfp_read_field_def_Package(Rest, Z1, Z2, F1,
			       TrUserData).




d_enum_YankReason(0) -> 'YANKED_OTHER';
d_enum_YankReason(1) -> 'YANKED_INVALID';
d_enum_YankReason(2) -> 'YANKED_SECURITY';
d_enum_YankReason(3) -> 'YANKED_DEPRECATED';
d_enum_YankReason(4) -> 'YANKED_RENAMED';
d_enum_YankReason(V) -> V.



merge_msgs(Prev, New, MsgName) ->
    merge_msgs(Prev, New, MsgName, []).

merge_msgs(Prev, New, MsgName, Opts) ->
    TrUserData = proplists:get_value(user_data, Opts),
    case MsgName of
      'YankStatus' ->
	  merge_msg_YankStatus(Prev, New, TrUserData);
      'Dependency' ->
	  merge_msg_Dependency(Prev, New, TrUserData);
      'Release' -> merge_msg_Release(Prev, New, TrUserData);
      'Package' -> merge_msg_Package(Prev, New, TrUserData)
    end.

merge_msg_YankStatus(#{reason := PFreason} = PMsg,
		     #{reason := NFreason} = NMsg, _) ->
    S1 = #{reason =>
	       if NFreason =:= undefined -> PFreason;
		  true -> NFreason
	       end},
    case {PMsg, NMsg} of
      {_, #{message := NFmessage}} ->
	  S1#{message => NFmessage};
      {#{message := PFmessage}, _} ->
	  S1#{message => PFmessage};
      _ -> S1
    end.

merge_msg_Dependency(#{package := PFpackage,
		       requirement := PFrequirement} =
			 PMsg,
		     #{package := NFpackage, requirement := NFrequirement} =
			 NMsg,
		     _) ->
    S1 = #{package =>
	       if NFpackage =:= undefined -> PFpackage;
		  true -> NFpackage
	       end,
	   requirement =>
	       if NFrequirement =:= undefined -> PFrequirement;
		  true -> NFrequirement
	       end},
    S2 = case {PMsg, NMsg} of
	   {_, #{optional := NFoptional}} ->
	       S1#{optional => NFoptional};
	   {#{optional := PFoptional}, _} ->
	       S1#{optional => PFoptional};
	   _ -> S1
	 end,
    case {PMsg, NMsg} of
      {_, #{app := NFapp}} -> S2#{app => NFapp};
      {#{app := PFapp}, _} -> S2#{app => PFapp};
      _ -> S2
    end.

merge_msg_Release(#{version := PFversion,
		    checksum := PFchecksum,
		    dependencies := PFdependencies} =
		      PMsg,
		  #{version := NFversion, checksum := NFchecksum,
		    dependencies := NFdependencies} =
		      NMsg,
		  TrUserData) ->
    S1 = #{version =>
	       if NFversion =:= undefined -> PFversion;
		  true -> NFversion
	       end,
	   checksum =>
	       if NFchecksum =:= undefined -> PFchecksum;
		  true -> NFchecksum
	       end,
	   dependencies =>
	       'erlang_++'(PFdependencies, NFdependencies,
			   TrUserData)},
    case {PMsg, NMsg} of
      {#{yanked := PFyanked}, #{yanked := NFyanked}} ->
	  S1#{yanked =>
		  merge_msg_YankStatus(PFyanked, NFyanked, TrUserData)};
      {_, #{yanked := NFyanked}} -> S1#{yanked => NFyanked};
      {#{yanked := PFyanked}, _} -> S1#{yanked => PFyanked};
      {_, _} -> S1
    end.

merge_msg_Package(#{releases := PFreleases},
		  #{releases := NFreleases}, TrUserData) ->
    #{releases =>
	  'erlang_++'(PFreleases, NFreleases, TrUserData)}.



verify_msg(Msg, MsgName) ->
    verify_msg(Msg, MsgName, []).

verify_msg(Msg, MsgName, Opts) ->
    TrUserData = proplists:get_value(user_data, Opts),
    case MsgName of
      'YankStatus' ->
	  v_msg_YankStatus(Msg, ['YankStatus'], TrUserData);
      'Dependency' ->
	  v_msg_Dependency(Msg, ['Dependency'], TrUserData);
      'Release' ->
	  v_msg_Release(Msg, ['Release'], TrUserData);
      'Package' ->
	  v_msg_Package(Msg, ['Package'], TrUserData);
      _ -> mk_type_error(not_a_known_message, Msg, [])
    end.


-dialyzer({nowarn_function,v_msg_YankStatus/3}).
v_msg_YankStatus(#{reason := F1} = M, Path, _) ->
    v_enum_YankReason(F1, [reason | Path]),
    case M of
      #{message := F2} -> v_type_string(F2, [message | Path]);
      _ -> ok
    end,
    ok;
v_msg_YankStatus(M, Path, _TrUserData) when is_map(M) ->
    mk_type_error({missing_fields, [reason] -- maps:keys(M),
		   'YankStatus'},
		  M, Path);
v_msg_YankStatus(X, Path, _TrUserData) ->
    mk_type_error({expected_msg, 'YankStatus'}, X, Path).

-dialyzer({nowarn_function,v_msg_Dependency/3}).
v_msg_Dependency(#{package := F1, requirement := F2} =
		     M,
		 Path, _) ->
    v_type_string(F1, [package | Path]),
    v_type_string(F2, [requirement | Path]),
    case M of
      #{optional := F3} -> v_type_bool(F3, [optional | Path]);
      _ -> ok
    end,
    case M of
      #{app := F4} -> v_type_string(F4, [app | Path]);
      _ -> ok
    end,
    ok;
v_msg_Dependency(M, Path, _TrUserData) when is_map(M) ->
    mk_type_error({missing_fields,
		   [package, requirement] -- maps:keys(M), 'Dependency'},
		  M, Path);
v_msg_Dependency(X, Path, _TrUserData) ->
    mk_type_error({expected_msg, 'Dependency'}, X, Path).

-dialyzer({nowarn_function,v_msg_Release/3}).
v_msg_Release(#{version := F1, checksum := F2,
		dependencies := F3} =
		  M,
	      Path, TrUserData) ->
    v_type_string(F1, [version | Path]),
    v_type_bytes(F2, [checksum | Path]),
    if is_list(F3) ->
	   _ = [v_msg_Dependency(Elem, [dependencies | Path],
				 TrUserData)
		|| Elem <- F3],
	   ok;
       true ->
	   mk_type_error({invalid_list_of, {msg, 'Dependency'}},
			 F3, Path)
    end,
    case M of
      #{yanked := F4} ->
	  v_msg_YankStatus(F4, [yanked | Path], TrUserData);
      _ -> ok
    end,
    ok;
v_msg_Release(M, Path, _TrUserData) when is_map(M) ->
    mk_type_error({missing_fields,
		   [version, checksum, dependencies] -- maps:keys(M),
		   'Release'},
		  M, Path);
v_msg_Release(X, Path, _TrUserData) ->
    mk_type_error({expected_msg, 'Release'}, X, Path).

-dialyzer({nowarn_function,v_msg_Package/3}).
v_msg_Package(#{releases := F1}, Path, TrUserData) ->
    if is_list(F1) ->
	   _ = [v_msg_Release(Elem, [releases | Path], TrUserData)
		|| Elem <- F1],
	   ok;
       true ->
	   mk_type_error({invalid_list_of, {msg, 'Release'}}, F1,
			 Path)
    end,
    ok;
v_msg_Package(M, Path, _TrUserData) when is_map(M) ->
    mk_type_error({missing_fields,
		   [releases] -- maps:keys(M), 'Package'},
		  M, Path);
v_msg_Package(X, Path, _TrUserData) ->
    mk_type_error({expected_msg, 'Package'}, X, Path).

-dialyzer({nowarn_function,v_enum_YankReason/2}).
v_enum_YankReason('YANKED_OTHER', _Path) -> ok;
v_enum_YankReason('YANKED_INVALID', _Path) -> ok;
v_enum_YankReason('YANKED_SECURITY', _Path) -> ok;
v_enum_YankReason('YANKED_DEPRECATED', _Path) -> ok;
v_enum_YankReason('YANKED_RENAMED', _Path) -> ok;
v_enum_YankReason(V, Path) when is_integer(V) ->
    v_type_sint32(V, Path);
v_enum_YankReason(X, Path) ->
    mk_type_error({invalid_enum, 'YankReason'}, X, Path).

-dialyzer({nowarn_function,v_type_sint32/2}).
v_type_sint32(N, _Path)
    when -2147483648 =< N, N =< 2147483647 ->
    ok;
v_type_sint32(N, Path) when is_integer(N) ->
    mk_type_error({value_out_of_range, sint32, signed, 32},
		  N, Path);
v_type_sint32(X, Path) ->
    mk_type_error({bad_integer, sint32, signed, 32}, X,
		  Path).

-dialyzer({nowarn_function,v_type_bool/2}).
v_type_bool(false, _Path) -> ok;
v_type_bool(true, _Path) -> ok;
v_type_bool(0, _Path) -> ok;
v_type_bool(1, _Path) -> ok;
v_type_bool(X, Path) ->
    mk_type_error(bad_boolean_value, X, Path).

-dialyzer({nowarn_function,v_type_string/2}).
v_type_string(S, Path) when is_list(S); is_binary(S) ->
    try unicode:characters_to_binary(S) of
      B when is_binary(B) -> ok;
      {error, _, _} ->
	  mk_type_error(bad_unicode_string, S, Path)
    catch
      error:badarg ->
	  mk_type_error(bad_unicode_string, S, Path)
    end;
v_type_string(X, Path) ->
    mk_type_error(bad_unicode_string, X, Path).

-dialyzer({nowarn_function,v_type_bytes/2}).
v_type_bytes(B, _Path) when is_binary(B) -> ok;
v_type_bytes(B, _Path) when is_list(B) -> ok;
v_type_bytes(X, Path) ->
    mk_type_error(bad_binary_value, X, Path).

-spec mk_type_error(_, _, list()) -> no_return().
mk_type_error(Error, ValueSeen, Path) ->
    Path2 = prettify_path(Path),
    erlang:error({gpb_type_error,
		  {Error, [{value, ValueSeen}, {path, Path2}]}}).


prettify_path([]) -> top_level;
prettify_path(PathR) ->
    list_to_atom(string:join(lists:map(fun atom_to_list/1,
				       lists:reverse(PathR)),
			     ".")).



-compile({nowarn_unused_function,id/2}).
-compile({inline,id/2}).
id(X, _TrUserData) -> X.

-compile({nowarn_unused_function,cons/3}).
-compile({inline,cons/3}).
cons(Elem, Acc, _TrUserData) -> [Elem | Acc].

-compile({nowarn_unused_function,lists_reverse/2}).
-compile({inline,lists_reverse/2}).
'lists_reverse'(L, _TrUserData) -> lists:reverse(L).

-compile({nowarn_unused_function,'erlang_++'/3}).
-compile({inline,'erlang_++'/3}).
'erlang_++'(A, B, _TrUserData) -> A ++ B.



get_msg_defs() ->
    [{{enum, 'YankReason'},
      [{'YANKED_OTHER', 0}, {'YANKED_INVALID', 1},
       {'YANKED_SECURITY', 2}, {'YANKED_DEPRECATED', 3},
       {'YANKED_RENAMED', 4}]},
     {{msg, 'YankStatus'},
      [#{name => reason, fnum => 1, rnum => 2,
	 type => {enum, 'YankReason'}, occurrence => required,
	 opts => []},
       #{name => message, fnum => 2, rnum => 3, type => string,
	 occurrence => optional, opts => []}]},
     {{msg, 'Dependency'},
      [#{name => package, fnum => 1, rnum => 2,
	 type => string, occurrence => required, opts => []},
       #{name => requirement, fnum => 2, rnum => 3,
	 type => string, occurrence => required, opts => []},
       #{name => optional, fnum => 3, rnum => 4, type => bool,
	 occurrence => optional, opts => []},
       #{name => app, fnum => 4, rnum => 5, type => string,
	 occurrence => optional, opts => []}]},
     {{msg, 'Release'},
      [#{name => version, fnum => 1, rnum => 2,
	 type => string, occurrence => required, opts => []},
       #{name => checksum, fnum => 2, rnum => 3, type => bytes,
	 occurrence => required, opts => []},
       #{name => dependencies, fnum => 3, rnum => 4,
	 type => {msg, 'Dependency'}, occurrence => repeated,
	 opts => []},
       #{name => yanked, fnum => 4, rnum => 5,
	 type => {msg, 'YankStatus'}, occurrence => optional,
	 opts => []}]},
     {{msg, 'Package'},
      [#{name => releases, fnum => 1, rnum => 2,
	 type => {msg, 'Release'}, occurrence => repeated,
	 opts => []}]}].


get_msg_names() ->
    ['YankStatus', 'Dependency', 'Release', 'Package'].


get_enum_names() -> ['YankReason'].


fetch_msg_def(MsgName) ->
    case find_msg_def(MsgName) of
      Fs when is_list(Fs) -> Fs;
      error -> erlang:error({no_such_msg, MsgName})
    end.


fetch_enum_def(EnumName) ->
    case find_enum_def(EnumName) of
      Es when is_list(Es) -> Es;
      error -> erlang:error({no_such_enum, EnumName})
    end.


find_msg_def('YankStatus') ->
    [#{name => reason, fnum => 1, rnum => 2,
       type => {enum, 'YankReason'}, occurrence => required,
       opts => []},
     #{name => message, fnum => 2, rnum => 3, type => string,
       occurrence => optional, opts => []}];
find_msg_def('Dependency') ->
    [#{name => package, fnum => 1, rnum => 2,
       type => string, occurrence => required, opts => []},
     #{name => requirement, fnum => 2, rnum => 3,
       type => string, occurrence => required, opts => []},
     #{name => optional, fnum => 3, rnum => 4, type => bool,
       occurrence => optional, opts => []},
     #{name => app, fnum => 4, rnum => 5, type => string,
       occurrence => optional, opts => []}];
find_msg_def('Release') ->
    [#{name => version, fnum => 1, rnum => 2,
       type => string, occurrence => required, opts => []},
     #{name => checksum, fnum => 2, rnum => 3, type => bytes,
       occurrence => required, opts => []},
     #{name => dependencies, fnum => 3, rnum => 4,
       type => {msg, 'Dependency'}, occurrence => repeated,
       opts => []},
     #{name => yanked, fnum => 4, rnum => 5,
       type => {msg, 'YankStatus'}, occurrence => optional,
       opts => []}];
find_msg_def('Package') ->
    [#{name => releases, fnum => 1, rnum => 2,
       type => {msg, 'Release'}, occurrence => repeated,
       opts => []}];
find_msg_def(_) -> error.


find_enum_def('YankReason') ->
    [{'YANKED_OTHER', 0}, {'YANKED_INVALID', 1},
     {'YANKED_SECURITY', 2}, {'YANKED_DEPRECATED', 3},
     {'YANKED_RENAMED', 4}];
find_enum_def(_) -> error.


enum_symbol_by_value('YankReason', Value) ->
    enum_symbol_by_value_YankReason(Value).


enum_value_by_symbol('YankReason', Sym) ->
    enum_value_by_symbol_YankReason(Sym).


enum_symbol_by_value_YankReason(0) -> 'YANKED_OTHER';
enum_symbol_by_value_YankReason(1) -> 'YANKED_INVALID';
enum_symbol_by_value_YankReason(2) -> 'YANKED_SECURITY';
enum_symbol_by_value_YankReason(3) ->
    'YANKED_DEPRECATED';
enum_symbol_by_value_YankReason(4) -> 'YANKED_RENAMED'.


enum_value_by_symbol_YankReason('YANKED_OTHER') -> 0;
enum_value_by_symbol_YankReason('YANKED_INVALID') -> 1;
enum_value_by_symbol_YankReason('YANKED_SECURITY') -> 2;
enum_value_by_symbol_YankReason('YANKED_DEPRECATED') ->
    3;
enum_value_by_symbol_YankReason('YANKED_RENAMED') -> 4.


get_service_names() -> [].


get_service_def(_) -> error.


get_rpc_names(_) -> error.


find_rpc_def(_, _) -> error.



-spec fetch_rpc_def(_, _) -> no_return().
fetch_rpc_def(ServiceName, RpcName) ->
    erlang:error({no_such_rpc, ServiceName, RpcName}).


get_package_name() -> undefined.



gpb_version_as_string() ->
    "3.24.3".

gpb_version_as_list() ->
    [3,24,3].
