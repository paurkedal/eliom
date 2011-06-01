
(** Pervasives module for Eliom extending stdlib, should always be opened. *)

exception Eliom_Internal_Error of string

external id : 'a -> 'a = "%identity"

val ( >>= ) : 'a Lwt.t -> ('a -> 'b Lwt.t) -> 'b Lwt.t
val ( >|= ) : 'a Lwt.t -> ('a -> 'b) -> 'b Lwt.t
val ( !! ) : 'a Lazy.t -> 'a

(* val comp : ('a -> 'b) -> ('c -> 'a) -> 'c -> 'b *)
(* val uncurry2 : ('a -> 'b -> 'c) -> 'a * 'b -> 'c *)
val map_option : ('a -> 'b) -> 'a option -> 'b option

(* val fst3 : 'a * 'b * 'c -> 'a *)
(* val snd3 : 'a * 'b * 'c -> 'b *)
(* val thd3 : 'a * 'b * 'c -> 'c *)

(* type yesnomaybe = Yes | No | Maybe *)
type ('a, 'b) leftright = Left of 'a | Right of 'b

type poly
val from_poly: poly -> 'a
type 'a client_expr = int64 * poly
type 'a wrapped_value = poly * 'a

exception False

module List : sig
  include module type of List
  (* val remove_first_if_any : 'a -> 'a list -> 'a list *)
  (* val remove_first_if_any_q : 'a -> 'a list -> 'a list *)
  (* val remove_first : 'a -> 'a list -> 'a list *)
  (* val remove_first_q : 'a -> 'a list -> 'a list *)
  (* val remove_all : 'a -> 'a list -> 'a list *)
  (* val remove_all_q : 'a -> 'a list -> 'a list *)
  (* val remove_all_assoc : 'a -> ('a * 'b) list -> ('a * 'b) list *)
  (* val remove_all_assoc_q : 'a -> ('a * 'b) list -> ('a * 'b) list *)
  (* val last : 'a list -> 'a *)
  (* val assoc_remove : 'a -> ('a * 'b) list -> 'b * ('a * 'b) list *)
  (* val is_prefix : 'a list -> 'a list -> bool *)
  val is_prefix_skip_end_slash : string list -> string list -> bool
  val chop : int -> 'a list -> 'a list
end

module String : sig
  include module type of String
  (* val remove_spaces : string -> int -> int -> string *)
  (* val basic_sep : char -> string -> string * string *)
  (* val sep : char -> string -> string * string *)
  val split : ?multisep:bool -> char -> string -> string list
  (* val may_append : string -> sep:string -> string -> string *)
  val may_concat : string -> sep:string -> string -> string
  (* val first_diff : string -> string -> int -> int -> int *)
  module Table : Map.S with type key = string
  (* module Set : Set.S with type elt = string *)
end

module Url : sig
  include module type of Url
  type t = string
  (* type uri = string *)
  type path = string list
  val make_absolute_url :
      https:bool -> host:string -> port:int -> string -> t
  (* val remove_dotdot : string list -> string list *)
  (* val remove_end_slash : string -> string *)
  val remove_internal_slash : string list -> string list
  (* val change_empty_list : string list -> string list *)
  (* val add_end_slash_if_missing : string list -> string list *)
  (* val remove_slash_at_end : string list -> string list *)
  val remove_slash_at_beginning : string list -> string list
  (* val recursively_remove_slash_at_beginning : string list -> string list *)
  val decode : string -> string
  val encode : ?plus:bool -> string -> string
  val make_encoded_parameters : (string * string) list -> string
  val split_path : string -> string list
end

(*
module Ip_address : sig
  (* type t = IPv4 of int32 | IPv6 of int64 * int64 *)
  (* exception Invalid_ip_address of string *)
  (* val parse : string -> t * t option *)
  (* val match_ip : t * t option -> t -> bool *)
  (* val network_of_ip : ip:t -> mask:t -> t *)
end
*)

module Printexc : sig
  include module type of Printexc
  val register_exn_printer : ((exn -> string) -> exn -> string) -> unit
end

val debug : ('a, unit, string, unit) format4 -> 'a
val jsdebug : 'a -> unit
val alert : ('a, unit, string, unit) format4 -> 'a
val jsalert : Js.js_string Js.t -> unit

val to_json : ?typ:'a -> 'b -> string
val of_json : ?typ:'a -> string -> 'b

val encode_form_value : 'a -> string
val unmarshal_js_var : string -> 'a

val encode_header_value : 'a -> string

(** XML building and deconstructing. *)
module XML : sig

  (* GRGR FIXME *)

  type aname = string
  type attrib

  type caml_event =
    | CE_closure of (unit -> unit Lwt.t) client_expr
    | CE_a of (bool * string list) option
    | CE_form_get of (bool * string list) option
    | CE_form_post of (bool * string list) option

  type event =
    | Raw of string
    | Caml of caml_event

  type ename = string
  type elt
  type econtent = private
    | Empty
    | Comment of string
    | EncodedPCDATA of string
    | PCDATA of string
    | Entity of string
    | Leaf of ename * attrib list
    | Node of ename * attrib list * elt list

  (**/**)

  val event_of_service_a : (bool * Url.path) option -> event

  type separator = Space | Comma
  type acontent = private
    | AFloat of aname * float
    | AInt of aname * int
    | AStr of aname * string
    | AStrL of separator * aname * string list
  val acontent : attrib -> acontent

  type racontent =
    | RA of acontent
    | RACamlEvent of (aname * caml_event)
  val racontent : attrib -> racontent

  val aname : attrib -> aname

  val float_attrib : aname -> float -> attrib
  val int_attrib : aname -> int -> attrib
  val string_attrib : aname -> string -> attrib
  val space_sep_attrib : aname -> string list -> attrib
  val comma_sep_attrib : aname -> string list -> attrib
  val event_attrib : aname -> event -> attrib

  val content : elt -> econtent
  val get_unique_id : elt -> string option

  val pcdata : string -> elt
  val encodedpcdata : string -> elt
  val entity : string -> elt

  val empty : unit -> elt
  val comment : string -> elt

  val leaf : ?a:(attrib list) -> ename -> elt
  val node : ?a:(attrib list) -> ename -> elt list -> elt

  val cdata : string -> elt
  val cdata_script : string -> elt
  val cdata_style : string -> elt

  type node_id = string
  type ref_tree =
    | Ref_node of (node_id option * (string * caml_event) list * ref_tree list)
    | Ref_empty of int

end

module SVG : sig

  (** type safe SVG creation. *)
  module M : SVG_sigs.T with module XML := XML

end

module HTML5 : sig

  (** type safe HTML5 creation. *)
  module M : sig

    include HTML5_sigs.T with module XML := XML and module SVG := SVG.M

    val of_element : Dom_html.element Js.t -> 'a elt
    val of_html : Dom_html.htmlElement Js.t -> HTML5_types.html elt
    val of_head : Dom_html.headElement Js.t -> HTML5_types.head elt
    val of_link : Dom_html.linkElement Js.t -> HTML5_types.link elt
    val of_title : Dom_html.titleElement Js.t -> HTML5_types.title elt
    val of_meta : Dom_html.metaElement Js.t -> HTML5_types.meta elt
    val of_base : Dom_html.baseElement Js.t -> HTML5_types.base elt
    val of_style : Dom_html.styleElement Js.t -> HTML5_types.style elt
    val of_body : Dom_html.bodyElement Js.t -> HTML5_types.body elt
    val of_form : Dom_html.formElement Js.t -> HTML5_types.form elt
    val of_optGroup : Dom_html.optGroupElement Js.t -> HTML5_types.optgroup elt
    val of_option : Dom_html.optionElement Js.t -> HTML5_types.selectoption elt
    val of_select : Dom_html.selectElement Js.t -> HTML5_types.select elt
    val of_input : Dom_html.inputElement Js.t -> HTML5_types.input elt
    val of_textArea : Dom_html.textAreaElement Js.t -> HTML5_types.textarea elt
    val of_button : Dom_html.buttonElement Js.t -> HTML5_types.button elt
    val of_label : Dom_html.labelElement Js.t -> HTML5_types.label elt
    val of_fieldSet : Dom_html.fieldSetElement Js.t -> HTML5_types.fieldset elt
    val of_legend : Dom_html.legendElement Js.t -> HTML5_types.legend elt
    val of_uList : Dom_html.uListElement Js.t -> HTML5_types.ul elt
    val of_oList : Dom_html.oListElement Js.t -> HTML5_types.ol elt
    val of_dList : Dom_html.dListElement Js.t -> [`Dl] elt
    val of_li : Dom_html.liElement Js.t -> HTML5_types.li elt
    val of_div : Dom_html.divElement Js.t -> HTML5_types.div elt
    val of_paragraph : Dom_html.paragraphElement Js.t -> HTML5_types.p elt
    val of_heading : Dom_html.headingElement Js.t -> HTML5_types.heading elt
    val of_quote : Dom_html.quoteElement Js.t -> HTML5_types.blockquote elt
    val of_pre : Dom_html.preElement Js.t -> HTML5_types.pre elt
    val of_br : Dom_html.brElement Js.t -> HTML5_types.br elt
    val of_hr : Dom_html.hrElement Js.t -> HTML5_types.hr elt
    val of_anchor : Dom_html.anchorElement Js.t -> 'a HTML5_types.a elt
    val of_image : Dom_html.imageElement Js.t -> [`Img] elt
    val of_object : Dom_html.objectElement Js.t -> 'a HTML5_types.object_ elt
    val of_param : Dom_html.paramElement Js.t -> HTML5_types.param elt
    val of_area : Dom_html.areaElement Js.t -> HTML5_types.area elt
    val of_map : Dom_html.mapElement Js.t -> 'a HTML5_types.map elt
    val of_script : Dom_html.scriptElement Js.t -> HTML5_types.script elt
    val of_tableCell : Dom_html.tableCellElement Js.t -> [ HTML5_types.td | HTML5_types.td ] elt
    val of_tableRow : Dom_html.tableRowElement Js.t -> HTML5_types.tr elt
    val of_tableCol : Dom_html.tableColElement Js.t -> HTML5_types.col elt
    val of_tableSection : Dom_html.tableSectionElement Js.t -> [ HTML5_types.tfoot | HTML5_types.thead | HTML5_types.tbody ] elt
    val of_tableCaption : Dom_html.tableCaptionElement Js.t -> HTML5_types.caption elt
    val of_table : Dom_html.tableElement Js.t -> HTML5_types.table elt
    val of_canvas : Dom_html.canvasElement Js.t -> 'a HTML5_types.canvas elt
    val of_iFrame : Dom_html.iFrameElement Js.t -> HTML5_types.iframe elt

  end

end

module Regexp : sig
  type t
  type flag = Global_search | Case_insensitive | Multi_line
  val last_index : t -> int
  val make :
      ?global:bool ->
	?case_insensitive:bool -> ?multi_line:bool -> string -> t
  val test : t -> string -> bool
  val exec : t -> string -> string array
  val index : t -> string -> int
  val replace : t -> string -> string -> string
  val replace_fun : t -> (int -> string array -> string) -> string -> string
  val split : t -> string -> string array
end

type file_info
