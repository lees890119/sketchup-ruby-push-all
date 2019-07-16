# Copyright 2019 Wei-Yu Lee
# Licensed under the MIT license

# PUSHALL Pushing all selected faces to a specified depth. 
# 	PUSHALL(DEPTH) Pushes all selected faces to a DEPTH in [mm].
#	
#	* This function also clears the inner faces of the model
#	  and group them based on individual solids.
#

require 'sketchup.rb'

module AutoTool
	module PushAll
		# Function for pushing all the surfaces.
		def self.pushAll(depth)
			plotDepth = depth.mm
			
			mod = Sketchup.active_model
			curSel = *(0..mod.selection.length-1).map {|x| mod.selection[x]}
			curSel = curSel.find_all {|x| (x.instance_of? Sketchup::Face or x.instance_of? Sketchup::Edge)}
			
			allSel = curSel.map{|x| x.all_connected}.flatten.uniq
			allFace = allSel.find_all {|x| x.instance_of? Sketchup::Face}

			normalVector = Geom::Vector3d.new(0,1,0)
			allFace.each do |currentFace|
				if currentFace.normal.samedirection?(normalVector)
					currentFace.reverse!
				end
				currentFace.pushpull(plotDepth, true)
				currentFace.reverse!
			end
			mod.selection.clear
			curSel
		end
		
		# Function for clearing inner faces.
		def self.clearInnerFace(curSel)
			ent = Sketchup.active_model.entities
			allSel = curSel.map{|x| x.all_connected}.flatten.uniq
			allEdge = allSel.find_all {|x| x.instance_of? Sketchup::Edge}
			
			normalVector = Geom::Vector3d.new(0,1,0)
			redundantEdge = allEdge.find_all {|x| x.faces.length == 3}
			redundantEdge = redundantEdge.find_all {|x| x.line[1].perpendicular?(normalVector)}
			
			redundantFace = redundantEdge.map {|x| x.faces}.flatten			
			redundantFace = redundantFace.find_all {|x| !x.normal.parallel?(normalVector)}
			
			ent.erase_entities redundantFace
			
			isolateEdge = allEdge.find_all {|x| x.faces.length == 0}
			
			ent.erase_entities isolateEdge
		end

		# Function for grouping all the models.
		def self.groupAll(curSel)
			ent = Sketchup.active_model.entities
			allSel = curSel.map{|x| x.all_connected}.flatten.uniq
			
			loopCount = [0,0]
			while allSel.length != 0 && loopCount[0] < 100
				connect = allSel[0].all_connected				
				grp = ent.add_group(connect)
				
				allSel = allSel-connect
				
				if grp.manifold?
					loopCount[0] = loopCount[0]+1
				else
					loopCount[1] = loopCount[1]+1
				end
			end
			loopCount
		end
		
		# Execute the pushAll function.
		def self.init
			
			mod = Sketchup.active_model
			sel = mod.selection
			
			if sel.length > 0
				begin				
					prompts = ["Depth to push [mm]: "]
					defaults = ["1000"]
					depth = UI.inputbox(prompts, defaults, "Enter push depth")

					mod.start_operation('PushAll', true)
				
					curSel = self.pushAll(depth[0].to_f)
					self.clearInnerFace(curSel)
					count = self.groupAll(curSel)
					UI.messagebox("Number of solid objects created: #{count[0]}\nNumber of Non-solid objects created: #{count[1]}")
				ensure		
					mod.commit_operation
				end
			else
				UI.messagebox("Please select the edges or faces to push.")
			end
		end		
		
		unless file_loaded?(__FILE__)
			menu = UI.menu('Plugins')
			menu.add_item('Push All') {
				self.init
			}
						
			file_loaded(__FILE__)
		end

	end # module PushAll
end # module AutoTool
