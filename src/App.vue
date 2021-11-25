<template>
    <Lunchbox background="#fbdf74">
        <pointLight :position="[0, 5, 5]" />

        <mesh
            position-z="-5"
            :rotation="[rotation, rotation, 0]"
            @click="rotating = !rotating"
            @added="onAdded"
        >
            <torusKnotGeometry :args="[1, 0.4, 150, 40]" />
            <!-- <planeGeometry /> -->
            <!-- <boxGeometry /> -->
            <!-- <icosahedronGeometry /> -->
            <meshBasicMaterial />
            <!-- <crosshatchMaterial /> -->
            <!-- <shaderMaterial
                :fragmentShader="speckled"
                :vertexShader="speckledVert"
                :uniforms="uniforms"
            /> -->
        </mesh>
    </Lunchbox>
</template>

<script lang="ts" setup>
import { reactive, ref } from 'vue'
import { onBeforeRender, setCustomRender } from 'lunchboxjs'
import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer'
import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass'
import * as THREE from 'three'
import { CustomOutlinePass } from './CustomOutlinePass'
import speckledVert from './speckledVert.glsl?raw'
import speckled from './speckled.glsl?raw'
import { CrosshatchMaterial } from './crosshatch/CrosshatchMaterial'

// Effect composer
// ====================
let composer: EffectComposer | null = null
setCustomRender((opts) => {
    const canvas = opts.renderer?.domElement
    // ignore if no canvas
    if (!canvas || !opts.scene || !opts.camera) return

    // setup effect composer if needed
    if (!composer) {
        composer = new EffectComposer(opts.renderer! as any)
        const renderPass = new RenderPass(opts.scene as any, opts.camera as any)
        composer.addPass(renderPass)

        // add other passes
        const passes = prepPasses(
            composer,
            opts.scene as any,
            opts.camera as any
        )
        passes.forEach((pass) => composer!.addPass(pass))
    }
    composer.render()
})

// Extra passes
// ====================
let depthTexture: THREE.DepthTexture
let depthTarget: THREE.WebGLRenderTarget
const prepPasses = (
    composer: EffectComposer,
    scene: THREE.Scene,
    camera: THREE.Camera
) => {
    const { width, height } = composer.renderer.domElement

    // create depth texture
    // depthTexture = new THREE.DepthTexture(width, height)

    // // save texture to renderer
    // depthTarget = new THREE.WebGLRenderTarget(width, height, {
    //     depthTexture,
    //     depthBuffer: true,
    // })

    const outlinePass = new CustomOutlinePass(
        new THREE.Vector2(width, height),
        scene,
        camera
    )

    return [outlinePass]
}

// Resize
// ====================
function onWindowResize() {
    if (!composer) return
    composer.setSize(window.innerWidth, window.innerHeight)
    composer.passes.forEach((pass) => {
        pass.setSize(
            window.innerWidth * window.devicePixelRatio,
            window.innerHeight * window.devicePixelRatio
        )
    })
}
window.addEventListener('resize', onWindowResize, false)

// Rotation
// ====================
const rotation = ref(0.5)
const rotating = ref(false)
onBeforeRender(() => {
    if (rotating.value) {
        rotation.value -= 0.008
    }
})

// Speckle material
// ====================
const onAdded = ({ instance }: { instance: THREE.Mesh }) => {
    instance.material = CrosshatchMaterial
}
const uniforms = reactive({
    uTime: { value: 0.0 },
})
onBeforeRender(() => {
    uniforms.uTime.value += 0.0166
})
</script>