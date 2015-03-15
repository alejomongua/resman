# encoding: utf-8
<% if namespaced? -%>
require_dependency "<%= namespaced_file_path %>/application_controller"

<% end -%>
<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController
  before_action :set_<%= singular_table_name %>, except: [:index, :new, :create]
  before_action :usuario_identificado
  respond_to :json
  
  # GET <%= route_url %>
  # GET <%= route_url %>.json
  def index
    @<%= plural_table_name %> = <%= class_name %>.busqueda(params[:buscar]).paginate(page: params[:page])

      render <%= "json: @#{plural_table_name}" %>
    end
  end

  # GET <%= route_url %>/1
  # GET <%= route_url %>/1.json
  def show
    render <%= "json: @#{singular_table_name}" %>
  end

  # POST <%= route_url %>
  # POST <%= route_url %>.json
  def create
    @<%= singular_table_name %> = <%= orm_class.build(class_name, "#{singular_table_name}_params") %>
    log = t :e_<%= singular_table_name %>_creado, <%= singular_table_name %>: @<%= singular_table_name %>.attributes

    if @<%= orm_instance.save %>
      Resque.enqueue(EventoQueue, usuario_actual.id, log, Time.now)
      render <%= "json: @#{singular_table_name}" %>, <%= 'status: :created' %>, <%= "location: @#{singular_table_name}" %>
    else
      render <%= "json: @#{orm_instance.errors}" %>, <%= 'status: :unprocessable_entity' %>
    end
  end

  # PUT <%= route_url %>/1
  # PUT <%= route_url %>/1.json
  def update
    @<%= singular_table_name %>.assign_attributes(<%= "#{singular_table_name}_params" %>)
    log = t :e_<%= singular_table_name %>_actualizado, id: @<%= singular_table_name %>.id, cambios: @<%= singular_table_name %>.changes

    if @<%= orm_instance.save %>
      Resque.enqueue(EventoQueue, usuario_actual.id, log, Time.now)
      head :no_content
    else
      render <%= "json: @#{orm_instance.errors}" %>, <%= "status: ':unprocessable_entity'" %>
    end
  end

  # DELETE <%= route_url %>/1
  # DELETE <%= route_url %>/1.json
  def destroy
    @<%= singular_table_name %>.inactivo = true

    log = t :e_<%= singular_table_name %>_eliminado, id: @<%= singular_table_name %>.id
    if @<%= singular_table_name %>.save
      Resque.enqueue(EventoQueue, usuario_actual.id, log, Time.now)
      head :no_content
    else
      render json: @<%= singular_table_name %>.errors, status: ':unprocessable_entity'
    end
  end

  def reactivar
    @<%= singular_table_name %>.inactivo = false

    log = t :e_<%= singular_table_name %>_restaurado, id: @<%= singular_table_name %>.id
    if @<%= singular_table_name %>.save
      Resque.enqueue(EventoQueue, usuario_actual.id, log, Time.now)
      head :no_content
    else
      render json: @<%= singular_table_name %>.errors, status: ':unprocessable_entity'
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_<%= singular_table_name %>
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
  end

  # Only allow a trusted parameter "white list" through.
  def <%= "#{singular_table_name}_params" %>
        <%- if attributes_names.empty? -%>
            params[<%= ":#{singular_table_name}" %>]
    <%- else -%>
    params.require(<%= ":#{singular_table_name}" %>).permit(<%= attributes_names.map { |name| ":#{name}" if name != 'inactivo' && name != 'check' }.join(', ') %>)
    <%- end -%>
  end
end
<% end -%>