import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import GUI from 'lil-gui'
import waterVertexShader from './shaders/water/vertex.glsl'
import waterFragmentShader from './shaders/water/fragment.glsl'

/**
 * Base Setup
 */
// Initialize debug UI
const gui = new GUI({ width: 340 })
const debugObject = {}

// Get canvas element
const canvas = document.querySelector('canvas.webgl')

// Create Three.js scene
const scene = new THREE.Scene()



/**
 * Water Setup
 */
// Create a plane geometry for water surface
const waterGeometry = new THREE.PlaneGeometry(2, 2, 512, 512);  // 512x512 segments for detailed waves
waterGeometry.deleteAttribute('normal')
waterGeometry.deleteAttribute('uv')

// Define default colors for debug controls
debugObject.depthColor = '#ff4000'    // Deep water color (orange)
debugObject.surfaceColor = '#151c37'  // Surface water color (dark blue)

// Add color controls to debug UI
gui.addColor(debugObject, 'depthColor').onChange(() => { waterMaterial.uniforms.uDepthColor.value.set(debugObject.depthColor) })
gui.addColor(debugObject, 'surfaceColor').onChange(() => { waterMaterial.uniforms.uSurfaceColor.value.set(debugObject.surfaceColor) })

// Create custom shader material for water
const waterMaterial = new THREE.ShaderMaterial({
    vertexShader: waterVertexShader,
    fragmentShader: waterFragmentShader,
    uniforms:
    {
        uTime: { value: 0 },  // Time for animation

        // Big waves properties
        uBigWavesElevation: { value: 0.2 },
        uBigWavesFrequency: { value: new THREE.Vector2(4, 1.5) },
        uBigWavesSpeed: { value: 0.75 },

        // Small waves properties
        uSmallWavesElevation: { value: 0.15 },
        uSmallWavesFrequency: { value: 3 },
        uSmallWavesSpeed: { value: 0.2 },
        uSmallIterations: { value: 4 },

        // Color properties
        uDepthColor: { value: new THREE.Color(debugObject.depthColor) },
        uSurfaceColor: { value: new THREE.Color(debugObject.surfaceColor) },
        uColorOffset: { value: 0.925 },
        uColorMultiplier: { value: 1 }
    }
})

// Add wave controls to debug UI
gui.add(waterMaterial.uniforms.uBigWavesElevation, 'value').min(0).max(1).step(0.001).name('uBigWavesElevation')
gui.add(waterMaterial.uniforms.uBigWavesFrequency.value, 'x').min(0).max(10).step(0.001).name('uBigWavesFrequencyX')
gui.add(waterMaterial.uniforms.uBigWavesFrequency.value, 'y').min(0).max(10).step(0.001).name('uBigWavesFrequencyY')
gui.add(waterMaterial.uniforms.uBigWavesSpeed, 'value').min(0).max(4).step(0.001).name('uBigWavesSpeed')

// Add small waves controls to debug UI
gui.add(waterMaterial.uniforms.uSmallWavesElevation, 'value').min(0).max(1).step(0.001).name('uSmallWavesElevation')
gui.add(waterMaterial.uniforms.uSmallWavesFrequency, 'value').min(0).max(30).step(0.001).name('uSmallWavesFrequency')
gui.add(waterMaterial.uniforms.uSmallWavesSpeed, 'value').min(0).max(4).step(0.001).name('uSmallWavesSpeed')
gui.add(waterMaterial.uniforms.uSmallIterations, 'value').min(0).max(5).step(1).name('uSmallIterations')

// Add color controls to debug UI
gui.add(waterMaterial.uniforms.uColorOffset, 'value').min(0).max(1).step(0.001).name('uColorOffset')
gui.add(waterMaterial.uniforms.uColorMultiplier, 'value').min(0).max(10).step(0.001).name('uColorMultiplier')

// Create water mesh and add to scene
const water = new THREE.Mesh(waterGeometry, waterMaterial)
water.rotation.x = - Math.PI * 0.5  // Rotate to horizontal plane
scene.add(water)

/**
 * Handle Window Resize
 */
const sizes = {
    width: window.innerWidth,
    height: window.innerHeight
}

// Update sizes and renderer on window resize
window.addEventListener('resize', () => {
    // Update sizes
    sizes.width = window.innerWidth
    sizes.height = window.innerHeight

    // Update camera aspect ratio
    camera.aspect = sizes.width / sizes.height
    camera.updateProjectionMatrix()

    // Update renderer dimensions and pixel ratio
    renderer.setSize(sizes.width, sizes.height)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
})

/**
 * Camera Setup
 */
// Create perspective camera
const camera = new THREE.PerspectiveCamera(75, sizes.width / sizes.height, 0.1, 100)
camera.position.set(1, 1, 1)
scene.add(camera)

// Add orbital controls for camera
const controls = new OrbitControls(camera, canvas)
controls.enableDamping = true  // Add smooth camera movement

/**
 * Renderer Setup
 */
const renderer = new THREE.WebGLRenderer({
    canvas: canvas
})
renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
renderer.toneMapping = THREE.ACESFilmicToneMapping

/**
 * Animation Loop
 */
const clock = new THREE.Clock()

const tick = () => {
    // Get elapsed time for animations
    const elapsedTime = clock.getElapsedTime()

    // Update water time uniform for wave animation
    waterMaterial.uniforms.uTime.value = elapsedTime * 1.5

    // Update orbital controls
    controls.update()

    // Render scene
    renderer.render(scene, camera)

    // Continue animation loop
    window.requestAnimationFrame(tick)
}

// Start animation loop
tick()