%% -------------------------------------------------------------------
%%
%% Copyright (c) 2014 SyncFree Consortium.  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------
-module(clocksi_downstream).

-include("antidote.hrl").

-export([generate_downstream_op/6]).

%% @doc Returns downstream operation for upstream operation
%%      input: Update - upstream operation
%%      output: Downstream operation or {error, Reason}
-spec generate_downstream_op(Transaction :: tx(), Node :: term(), Key :: key(),
    Type :: type(), Update :: {op(), actor()}, list()) ->
    {ok, op()} | {error, atom()}.
generate_downstream_op(Transaction, Node, Key, Type, Update, WriteSet) ->
    %% TODO: Check if read can be omitted for some types and ops
    case clocksi_vnode:read_data_item(Node,
                                      Transaction,
                                      Key,
                                      Type,
                                      WriteSet) of
        {ok, Snapshot} ->
            case Type of
                antidote_crdt_bcounter -> %% bcounter data-type.
                    bcounter_mgr:generate_downstream(Key,Update,Snapshot);
                _ ->
                    Type:downstream(Update, Snapshot)
            end;
        {error, Reason} -> {error, Reason}
    end.
