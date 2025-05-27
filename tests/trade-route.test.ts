import { describe, it, expect, beforeEach } from 'vitest'

// Mock Clarity testing environment for trade routes
const mockClarityEnv = {
  currentBlock: 1,
  currentSender: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
  contractMaps: new Map(),
  contractVars: new Map(),
  
  callPublic(contractName, functionName, args = [], sender = null) {
    if (sender) this.currentSender = sender
    this.contractVars.set('next-route-id', this.contractVars.get('next-route-id') || 1)
    return this[`${contractName}_${functionName}`](...args)
  },
  
  callReadOnly(contractName, functionName, args = []) {
    return this[`${contractName}_${functionName}`](...args)
  },
  
  // Trade Route Contract Implementation
  'trade-route_create-trade-route'(originPlanet, destinationPlanet, estimatedDuration, baseCost, maxCapacity) {
    const routeId = this.contractVars.get('next-route-id') || 1
    const tradeRoutes = this.contractMaps.get('trade-routes') || new Map()
    const routeCapacity = this.contractMaps.get('route-capacity') || new Map()
    
    tradeRoutes.set(routeId, {
      'origin-planet': originPlanet,
      'destination-planet': destinationPlanet,
      'route-operator': this.currentSender,
      'estimated-duration': estimatedDuration,
      'base-cost': baseCost,
      'is-active': true,
      'created-at': this.currentBlock
    })
    
    routeCapacity.set(routeId, {
      'max-capacity': maxCapacity,
      'current-load': 0
    })
    
    this.contractMaps.set('trade-routes', tradeRoutes)
    this.contractMaps.set('route-capacity', routeCapacity)
    this.contractVars.set('next-route-id', routeId + 1)
    
    return { type: 'ok', value: routeId }
  },
  
  'trade-route_book-route-capacity'(routeId, cargoSize) {
    const routeCapacity = this.contractMaps.get('route-capacity') || new Map()
    const capacity = routeCapacity.get(routeId)
    
    if (!capacity) {
      return { type: 'err', value: 2002 } // ERR-ROUTE-NOT-FOUND
    }
    
    if (capacity['current-load'] + cargoSize > capacity['max-capacity']) {
      return { type: 'err', value: 2003 } // ERR-ROUTE-FULL
    }
    
    capacity['current-load'] += cargoSize
    routeCapacity.set(routeId, capacity)
    this.contractMaps.set('route-capacity', routeCapacity)
    
    return { type: 'ok', value: true }
  },
  
  'trade-route_get-route-info'(routeId) {
    const tradeRoutes = this.contractMaps.get('trade-routes') || new Map()
    const route = tradeRoutes.get(routeId)
    return route ? { type: 'some', value: route } : { type: 'none' }
  },
  
  'trade-route_get-available-capacity'(routeId) {
    const routeCapacity = this.contractMaps.get('route-capacity') || new Map()
    const capacity = routeCapacity.get(routeId)
    if (!capacity) return { type: 'none' }
    
    const available = capacity['max-capacity'] - capacity['current-load']
    return { type: 'some', value: available }
  }
}

describe('Trade Route Contract', () => {
  beforeEach(() => {
    mockClarityEnv.contractMaps.clear()
    mockClarityEnv.contractVars.clear()
    mockClarityEnv.currentBlock = 1
  })
  
  it('should create a new trade route', () => {
    const result = mockClarityEnv.callPublic(
        'trade-route',
        'create-trade-route',
        ['earth', 'mars', 30, 1000, 5000]
    )
    
    expect(result.type).toBe('ok')
    expect(result.value).toBe(1)
    
    const routeInfo = mockClarityEnv.callReadOnly(
        'trade-route',
        'get-route-info',
        [1]
    )
    
    expect(routeInfo.type).toBe('some')
    expect(routeInfo.value['origin-planet']).toBe('earth')
    expect(routeInfo.value['destination-planet']).toBe('mars')
    expect(routeInfo.value['estimated-duration']).toBe(30)
    expect(routeInfo.value['max-capacity']).toBeUndefined() // This is in route-capacity map
  })
  
  it('should book route capacity successfully', () => {
    // Create route first
    mockClarityEnv.callPublic(
        'trade-route',
        'create-trade-route',
        ['mars', 'jupiter', 45, 2000, 10000]
    )
    
    const bookingResult = mockClarityEnv.callPublic(
        'trade-route',
        'book-route-capacity',
        [1, 3000]
    )
    
    expect(bookingResult.type).toBe('ok')
    expect(bookingResult.value).toBe(true)
    
    const availableCapacity = mockClarityEnv.callReadOnly(
        'trade-route',
        'get-available-capacity',
        [1]
    )
    
    expect(availableCapacity.type).toBe('some')
    expect(availableCapacity.value).toBe(7000) // 10000 - 3000
  })
  
  it('should reject booking when route is full', () => {
    // Create route with small capacity
    mockClarityEnv.callPublic(
        'trade-route',
        'create-trade-route',
        ['venus', 'earth', 20, 500, 1000]
    )
    
    const bookingResult = mockClarityEnv.callPublic(
        'trade-route',
        'book-route-capacity',
        [1, 1500] // More than capacity
    )
    
    expect(bookingResult.type).toBe('err')
    expect(bookingResult.value).toBe(2003) // ERR-ROUTE-FULL
  })
  
  it('should handle non-existent route booking', () => {
    const bookingResult = mockClarityEnv.callPublic(
        'trade-route',
        'book-route-capacity',
        [999, 100]
    )
    
    expect(bookingResult.type).toBe('err')
    expect(bookingResult.value).toBe(2002) // ERR-ROUTE-NOT-FOUND
  })
  
  it('should increment route IDs correctly', () => {
    const route1 = mockClarityEnv.callPublic(
        'trade-route',
        'create-trade-route',
        ['earth', 'mars', 30, 1000, 5000]
    )
    
    const route2 = mockClarityEnv.callPublic(
        'trade-route',
        'create-trade-route',
        ['mars', 'venus', 25, 1200, 4000]
    )
    
    expect(route1.value).toBe(1)
    expect(route2.value).toBe(2)
  })
})
