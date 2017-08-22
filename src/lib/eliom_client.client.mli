(* Ocsigen
 * http://www.ocsigen.org
 * Module eliom_client.ml
 * Copyright (C) 2010 Vincent Balat
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, with linking exception;
 * either version 2.1 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *)

(** Call server side services and change the current page. *)

open Eliom_lib

(** {2 Mobile applications} *)

(** Call this function if you want to be able to run your client side
    app before doing the first request, that is, when the client side
    app is not sent by the server. This may be the case for example if
    you are developing a mobile app. The parameters correspond to the
    base URL of the server side of your application.

    Alternatively, and to make sure it is done early enough, define
    JS variables called [__eliom_server] and [__eliom_app_name]
    at the beginning of your html
    file, containing the full URL of your server.

    [site_dir] (if given) specifies the path that the application runs
    under. It should correspond to the <site> tag of your server
    configuration. Calls to server functions use this path. *)
val init_client_app :
  app_name:string ->
  ?ssl:bool ->
  hostname:string ->
  ?port:int ->
  site_dir:Eliom_lib.Url.path -> unit -> unit

(** Returns whether the application is sent by a server or started on
    client side. If called on server side, always returns [false].
    Otherwise, it tests the presence of JS variables added automatically by
    Eliom when the page is sent by a server.
    Example:
    {[ if not (Eliom_client.is_client_app ())
 then Eliom_client.init_client_app ... ]}
*)
val is_client_app : unit -> bool


(** {2 Calling services} *)

(** Call a service and change the current page.  If the service
    belongs to the same application, the client side program is not
    stopped, and only the content (not the container) is reloaded.  If
    the [replace] flag is set, the new page will replace the current
    page in the browser history if the service belongs to the same
    application. The last two parameters are respectively the GET and
    POST parameters to send to the service. *)
val change_page :
  ?ignore_client_fun:bool ->
  ?replace:bool ->
  ?absolute:bool ->
  ?absolute_path:bool ->
  ?https:bool ->
  service:
    ('a, 'b, _, _, _, _, _, _, _, _, Eliom_service.non_ocaml)
      Eliom_service.t ->
  ?hostname:string ->
  ?port:int ->
  ?fragment:string ->
  ?keep_nl_params:[ `All | `None | `Persistent ] ->
  ?nl_params:Eliom_parameter.nl_params_set ->
  ?keep_get_na_params:bool ->
  ?progress:(int -> int -> unit) ->
  ?upload_progress:(int -> int -> unit) ->
  ?override_mime_type:string ->
  'a -> 'b -> unit Lwt.t

(** Call a server side service that return an OCaml value.

    If the service raises an exception, the call to the
    [call_ocaml_service] raises an exception {% <<a_api|exception
    Exception_on_server>> %} whose argument describes the server-side
    exception.
    (NB that we cannot send the original exception as-it, because
    OCaml permits the marshalling of exceptions ...)
*)
val call_ocaml_service :
  ?absolute:bool ->
  ?absolute_path:bool ->
  ?https:bool ->
  service:
    ('a, 'b, _, _, _, _, _, _, _, _, 'return Eliom_service.ocaml)
      Eliom_service.t ->
  ?hostname:string ->
  ?port:int ->
  ?fragment:string ->
  ?keep_nl_params:[ `All | `None | `Persistent ] ->
  ?nl_params:Eliom_parameter.nl_params_set ->
  ?keep_get_na_params:bool ->
  ?progress:(int -> int -> unit) ->
  ?upload_progress:(int -> int -> unit) ->
  ?override_mime_type:string ->
  'a -> 'b -> 'return Lwt.t


(** Stop current program and load a new page.  Note that for string arguments,
    sole line feed or sole carriage return characters are substituted by the
    string ["\r\n"]. *)
val exit_to :
  ?absolute:bool ->
  ?absolute_path:bool ->
  ?https:bool ->
  service:
    ('a, 'b, _, _, _, _, _, _, _, _, Eliom_service.non_ocaml)
      Eliom_service.t ->
  ?hostname:string ->
  ?port:int ->
  ?fragment:string ->
  ?keep_nl_params:[ `All | `None | `Persistent ] ->
  ?nl_params:Eliom_parameter.nl_params_set ->
  ?keep_get_na_params:bool ->
  'a -> 'b -> unit

(** Loads an Eliom service in a window (cf. Javascript's [window.open]). *)
val window_open :
  window_name:Js.js_string Js.t ->
  ?window_features:Js.js_string Js.t ->
  ?absolute:bool ->
  ?absolute_path:bool ->
  ?https:bool ->
  service:
    ('a, unit, Eliom_service.get, _, _, _, _, _, _, unit, _)
      Eliom_service.t ->
  ?hostname:string ->
  ?port:int ->
  ?fragment:string ->
  ?keep_nl_params:[ `All | `None | `Persistent ] ->
  ?nl_params:Eliom_parameter.nl_params_set ->
  ?keep_get_na_params:bool ->
  'a -> Dom_html.window Js.t Js.opt

(** Changes the URL, without doing a request.
    It takes a GET (co-)service as parameter and its parameters.
    If the [replace] flag is set, the current page is not saved
    in the history.
 *)
val change_url :
  ?replace:bool ->
  ?absolute:bool ->
  ?absolute_path:bool ->
  ?https:bool ->
  service:
    ('get, unit, Eliom_service.get,
     _, _, _, _, _, _, unit, _) Eliom_service.t ->
  ?hostname:string ->
  ?port:int ->
  ?fragment:string ->
  ?keep_nl_params:[ `All | `None | `Persistent ] ->
  ?nl_params:Eliom_parameter.nl_params_set ->
  'get -> unit

(** (low level) Call a server side service and return the content
    of the resulting HTTP frame as a string. *)
val call_service :
  ?absolute:bool ->
  ?absolute_path:bool ->
  ?https:bool ->
  service:('a, 'b, _, _, _, _, _, _, _, _, _) Eliom_service.t ->
  ?hostname:string ->
  ?port:int ->
  ?fragment:string ->
  ?keep_nl_params:[ `All | `None | `Persistent ] ->
  ?nl_params:Eliom_parameter.nl_params_set ->
  ?keep_get_na_params:bool ->
  ?progress:(int -> int -> unit) ->
  ?upload_progress:(int -> int -> unit) ->
  ?override_mime_type:string ->
  'a -> 'b -> string Lwt.t

(** {2 Misc} *)

(** Registers some code to be executed after loading the client
    application, or after changing the page the next time.

    It complements as a toplevel expression in the client
    module with the side effect from client values while
    creating the response of a service: While the latter are executed
    each time the service has been called; the former is executed only
    once; but each at a time where the document is in place:

    {% <<code language="ocaml"|
    [%%shared open Eliom_lib]
    [%%client
      let () = alert "Once only during initialization of the client, \
                      i.e. before the document is available."
      let () =
        Eliom_client.onload
          (fun () -> alert "Once only when the document is put in place.")
    ]
    [%%server
      let _ = My_app.register_service ~path ~get_params
        (fun () () ->
           ignore {unit{
             alert "Each time this service is called and the sent document \
                    is put in place."
           }};
           Lwt.return html
    ]
    >> %}

*)
val onload : (unit -> unit) -> unit

(** Returns a Lwt thread that waits until the next page is loaded. *)
val lwt_onload : unit -> unit Lwt.t


(** [Onchangepage_event] is a record of some parameters related to
    page changes. [back] is true if the page change is caused by a
    navigation back in history. [current_uri] is the uri of the
    current page and [target_uri] is the uri of the next page.
    Although users can access the current uri through [Url] module
    in [js_of_ocaml], we still provide [current_uri] because
    [Url.Current.path_string] doesn't return the correct path when it
    is called in a cordova application. *)
type onchangepage_event =
  {back:bool; current_uri:string; target_uri:string}

(** Run some code *before* the next page change, that is, before each
    call to a page-producing service handler.

    Just like onpreload, handlers registered with onchangepage only
    apply to the next page change. *)
val onchangepage : (onchangepage_event -> unit) -> unit

(** [onbeforeunload f] registers [f] as a handler to be called before
    changing the page the next time. If [f] returns [Some s], then we
    ask the user to confirm quitting. We try to use [s] in the
    confirmation pop-up. [None] means no confirmation needed.

    The callback [f] is sometimes trigerred by internal service calls,
    and sometimes by the browser [onbeforeunload] event. In the
    [onbeforeunload] case, the confirmation pop-up is managed by the
    browser. For Firefox, the string [s] returned by [f] is ignored:
    https://bugzilla.mozilla.org/show_bug.cgi?id=641509

    [onbeforeunload] can be used to register multiple callbacks. *)
val onbeforeunload : (unit -> string option) -> unit

(** [onunload f] registers [f] as a handler to be called before page
    change. The callback [f] is sometimes trigerred by internal
    service calls, and sometimes by the browser [onunload] event.
    [onunload] can be used to register multiple callbacks. *)
val onunload : (unit -> unit) -> unit

(** Wait for the initialization phase to terminate *)
val wait_load_end : unit -> unit Lwt.t

(** Returns the name of currently running Eliom application,
    defined while applying [Eliom_registration.App] functor. *)
val get_application_name : unit -> string

(** After this function is called, the document head is no
    longer changed on page change. *)
val persist_document_head : unit -> unit

(** {2 RPC / Server functions}

    See the {% <<a_manual chapter="clientserver-communication" fragment="rpc"|manual>> %}.*)

(** A [('a, 'b) server_function] provides transparently access to a
    server side function which has been created by {% <<a_api
    subproject="server"|Eliom_client.server_function>> %}.

    See also {% <<a_api subproject="server" text="the opaque server
    side representation"| type Eliom_client.server_function>> %}.

    The handling of exception on the server corresponds to that of
    <<a_api subproject="client"|val Eliom_client.call_ocaml_service>>.
*)
type ('a, +'b) server_function = 'a -> 'b Lwt.t

(** [change_page_uri ?replace uri] identifies and calls the
    client-side service that implements [uri].

    We fallback to a server service call if the service is not
    registered on the client.

    If the [replace] flag is set to [true], the current page is not
    saved in the history. *)
val change_page_uri : ?replace:bool -> string -> unit Lwt.t

(** Set the name of the HTML file loading our client app. The default
    is "eliom.html". A wrong value will not allow the app to
    initialize itself correctly. *)
val set_client_html_file : string -> unit

(**/**)

(** [change_page_unknown path get_params post_params] calls the
    service corresponding to [(path, get_params, post_params)]. It may
    throw [Eliom_common.Eliom_404] or
    [Eliom_common.Eliom_Wrong_parameter] if there is no appropriate
    service available. *)
val change_page_unknown :
  ?meth:[`Get | `Post | `Put | `Delete] ->
  ?hostname:string ->
  ?replace:bool ->
  string list ->
  (string * string) list ->
  (string * string) list ->
  unit Lwt.t

(* Documentation rather in eliom_client.ml *)

val init : unit -> unit

val set_reload_function : (unit -> unit -> unit Lwt.t) -> unit

(** Store the document/body of the current page, which will be used when going 
    back to this page in history. 
    A typical use case of this function is storing the dom when leaving 
    a page. i.e. [Eliom_client.onchangepage Eliom_client.push_history_dom ]
*)
val push_history_dom : unit -> unit

(** Install an onchangepage handler for the current page. When leaving this page,
    the function [push_history_dom] will be called. If history_changepage_handler
    is not null, it will be called with the current state id as the first parameter. 
*)
val install_history_changepage_handler : unit -> unit

(** Why do we need this function ?
    Suppose that we want to have a page transition on coming back from details 
    to list page, we need usually a parameter (e.g. a screenshot of the list 
    page) to realize the animation of page transition and the parameter is 
    generally created just before we leave the list page in order to store the
    latest information (such as the scroll position). Normally, in order to do this, 
    we register an onchangepage handler in the beginning of the handler of the service 
    that generates the list page. However, when we reload the list page by replacing 
    the current document/body with the one stored in cache, the handler will be lost.
    So we need a specific function to re-register the handler everytime the list
    page is reloaded from cache.    

    Suppose also that we have a hashtable which maps a state_id into a parameter 
    (e.g. a screenshot) corresponding to the page characterized by the state_id. 

    [set_history_changepage_handler f] registers an onchangepage handler for 
    the all pages reloaded from cache : [Eliom_client.onchangepage (f id)]. 
    Here f should take a state id as argument so that it can register a particular 
    handler for the page associated with the state_id.

    Notice that normally you need to call this function before installing the 
    changepage handler for any specific page, in other words, before calling 
    any [install_history_changepage_handler ()], so that the function 
    [install_history_changepage_handler] will execute the handler function 
    before leaving the page for the first time.
*)
val set_history_changepage_handler : (int -> onchangepage_event -> unit) -> unit

(** [set_animation_function f] sets the animation function which is used to
    realize the page transition on coming back in history. With the same
    suppositions in the comment of [set_history_changepage_handler],
    [f id ev replace_fun] first extracts the necessary parameter (e.g. a screenshot)
    from the hashtable with the given id. Then it uses [ev : onchangepage_event] to
    decide if there should be an animation of page transition. If so, it uses
    the parameter to realize the animation. Finally it calls the given function
    [replace_fun] to replace the document/body.
*)
val set_animation_function :
  (int -> onchangepage_event -> (unit -> unit Lwt.t) -> unit Lwt.t) -> unit

(** Lwt_log section for this module.
    Default level is [Lwt_log.Info].
    Use [Lwt_log.Section.set_level Eliom_client.log_section Lwt_log.Debug]
    to see debug messages.
*)
val log_section : Lwt_log.section

(** Is it a middle-click event? *)
val middleClick : Dom_html.mouseEvent Js.t -> bool

val set_content_local :
  ?offset:Eliommod_dom.position ->
  ?fragment:string -> Dom_html.element Js.t -> unit Lwt.t

type client_form_handler = Dom_html.event Js.t -> bool Lwt.t

val current_uri : string ref

type _ redirection =
    Redirection :
      (unit, unit, Eliom_service.get , _, _, _, _,
       [ `WithoutSuffix ], unit, unit, 'a) Eliom_service.t ->
    'a redirection

val register_redirect : Eliom_service.non_ocaml redirection -> unit

val register_reload : unit -> unit
