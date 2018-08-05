local M = {}

local TextColumn	= require 'TextColumn'
local Rect			= require 'Rect'

local __cairo_set_line_width	= cairo_set_line_width
local __cairo_set_line_cap		= cairo_set_line_cap
local __cairo_append_path		= cairo_append_path
local __cairo_stroke			= cairo_stroke
local __cairo_set_font_face		= cairo_set_font_face
local __cairo_set_font_size		= cairo_set_font_size
local __cairo_set_source		= cairo_set_source
local __cairo_move_to			= cairo_move_to
local __cairo_show_text			= cairo_show_text

local set = function(obj, cr, col_num, row_num, text)
	local column = obj.table.columns[col_num]
	TextColumn.set(column, cr, row_num, text)
end

local draw_static = function(obj, cr)
   -- draw border, headers, and separators
   Rect.draw(obj, cr)

   local tbl = obj.table
   local columns = tbl.columns
   
   local first_header = columns[1].header
   __cairo_set_source(cr, first_header.source)
   __cairo_set_font_face(cr, first_header.font_face)
   __cairo_set_font_size(cr, first_header.font_size)
	
   for c = 1, tbl.num_columns do
	  local header = columns[c].header
	  __cairo_move_to(cr, header.x, header.y)
	  __cairo_show_text(cr, header.text)
   end

   local separators = tbl.separators
   
   local first_separator = separators[1]
   __cairo_set_source(cr, first_separator.source)
   __cairo_set_line_width(cr, first_separator.thickness)
   __cairo_set_line_cap(cr, first_separator.cap)
	
   for i = 1, separators.n do
	  local line = separators[i]
	  __cairo_append_path(cr, line.path)
	  __cairo_stroke(cr)
   end
end

local draw_dynamic = function(obj, cr)
   -- draw each cell
   local this_table = obj.table
   local these_columns = this_table.columns
   local first_cell = these_columns[1].rows[1]
   __cairo_set_source(cr, first_cell.source)
   __cairo_set_font_face(cr, first_cell.font_face)
   __cairo_set_font_size(cr, first_cell.font_size)
	
   for c = 1, this_table.num_columns do
	  local these_rows = these_columns[c].rows
	  for r = 1, these_rows.n do
		 local this_cell = these_rows[r]
		 __cairo_move_to(cr, this_cell.x, this_cell.y)
		 __cairo_show_text(cr, this_cell.text)
	  end
   end
end

M.set = set
M.draw_static = draw_static
M.draw_dynamic = draw_dynamic

return M
