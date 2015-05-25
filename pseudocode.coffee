Constants = 
	α: 0.9
	ρ: 0.01


Ant = class
	constructor: (@currentVertex) ->
		@previousVertex = null
		@init()
		@deltaPheromon = 0.5
	init: ->
		@currentPath = [vertex: @currentVertex, cost: 0]
		@mode = "forward"
	
		

	doTurn: ->
		edge = @choseEdge()
		@moveAlong edge
		if @hasFoundFood()
			@mode = "backward"
			@optimizePath()
			console.log "foundFood, length: #{getCostOfCurrentPath()}"
			
		if @hasFoundFormicary()
			@mode = "forward"
			console.log "foundBackToFormicary, length: #{getCostOfCurrentPath()}"
			@init()
			
	choseEdge: ->
		if @mode is "forward"
			if @currentVertex.edges.length is 1 then @currentVertex.edges[0]
			totalPheromon = Tools.getTotalCost @currentVertex.edges, (edge) -> 
				if @getNeighbor(edge) isnt @previousVertex then Math.exp edge.pheromons, Contants.α else 0
			sample = Math.random()
			sumPossiblity = 0
			for edge in @currentVertex.edges
				if @getNeighbor(edge) isnt @previousVertex
					possibility = Math.exp(edge.pheromons, Contants.α) / totalPheromon
					return edge if sample < possibility
					sumPossiblity += possibility
		if @mode is "backward"

	moveAlong: (edge) ->
		@previousVertex = @currentVertex
		@currentPath.push 
			cost: edge.cost
			vertex: @currentVertex
		if @mode is "backward"
			@sprayPheromon edge
		@currentVertex = @getNeighbor edge

	optimizePath: ->
		loops = Tools.findLoops @currentPath
		longest = _.max loops, "totalCost"
		@currentPath = @currentPath[..@longest.startIndex].concat @currentPath[@longest.endIndex..] 
	
	getNeighbor: (edge) ->
		if edge.vertex1 isnt @currentVertex then edge.vertex1 else edge.vertex2
	
	getCostOfCurrentPath: ->
		Tools.sum @currentPath, (edge) -> edge.cost
	hasFoundFood: ->
		@mode is "forward" and @currentVertex instanceof FoodVertex
	hasFoundFormicary: ->
		@mode is "backward" and @currentVertex instanceof FormicaryVertex
	sprayPheromon: (edge) ->
		if withCost
			edge.pheromons += 1/L_K
		else
			edge.pheromons += @deltaPheromon

Graph = {}

Graph.Edge = class
	constructor: ({@name, @vertex1, @vertex2, @cost}) ->
		@vertex1.edges.push @
		@vertex2.edges.push @

Graph.AntEdge = class extends Graph.Edge
	constructor: ({@name, @vertex1, @vertex2, @cost, @pheromons = 0}) ->
		super {@name, @vertex1, @vertex2, @cost}

	updatePheromons: ->
		@pheromons *= 1-Constants.ρ


Graph.Vertex = class
	constructor: (@name) ->
		@edges = []

Graph.FoodVertex = class extends Graph.Vertex
	constructor: (@name) ->
		super()
		@hasFood = yes

Graph.FormicaryVertex = class extends Graph.Vertex
	constructor: (@name) ->
		super()
		@hasFood = yes


Tools = 
	sum: (list, iteratee) ->
		_.reduce edges, (total, edge) -> iteratee edge
		, 0
	findLoops: (path) ->
		counted = _.countBy path, ({vertex}) -> vertex
		loops = []
		for count, vertex in counted
			if count > 1
				firstIndex = _.findIndex path, ({aVertex}) -> aVertex is vertex
				lastIndex = _.findLastIndex path, ({aVertex}) -> aVertex is vertex
				loops.push path[firstIndex, lastIndex]
		return loops


# init experiment

vertices =
	A: new Graph.FormicaryVertex "A"
	B: new Graph.Vertex "B"
	C: new Graph.Vertex "C"
	D: new Graph.FoodVertex "D"

edges = [
	new Graph.AntEdge 
		name: "a_b", 
		vertex1: vertices.A, 
		vertex2: vertices.B, 
		cost: 5
	,
	new Graph.AntEdge 
		name: "b_c", 
		vertex1: vertices.B, 
		vertex2: vertices.C, 
		cost: 5
	,
	new Graph.AntEdge 
		name: "c_d", 
		vertex1: vertices.C,
		vertex2: vertices.D, 
		cost: 5
	,
	new Graph.AntEdge 
		name: "a_c", 
		vertex1: vertices.A,
		vertex2: vertices.C, 
		cost: 5
]


ants = for i in [1..10] 
	new Ant vertices.A

ticker = new Ticker 
	turn: ->
		ant.doTurn() for ant in ants
		edge.updatePheromons() for edge in edges



