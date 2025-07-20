#ifndef __PROJECTM_CWRAPPER_H__
#define __PROJECTM_CWRAPPER_H__

#include "projectM.hpp"

#define PROJECTM_VERSION_1_0_0 1000000
#define PROJECTM_VERSION_1_1_0 1001000
#define PROJECTM_VERSION_1_2_0 1002000
#define PROJECTM_VERSION_2_0_0 2000000
#define PROJECTM_VERSION_3_0_0 3000000

#ifndef PROJECTM_VERSION_INT
#define PROJECTM_VERSION_INT PROJECTM_VERSION_2_0_0
#endif

extern "C" {

    #if (PROJECTM_VERSION_INT > 1000000)
    struct Settings {
        int meshX;
        int meshY;
        int fps;
        int textureSize;
        int windowWidth;
        int windowHeight;
        const char* presetURL;
        const char* titleFontURL;
        const char* menuFontURL;        
        int smoothPresetDuration;
        int presetDuration;
        float beatSensitivity;
        char aspectCorrection;
        float easterEgg;
        char shuffleEnabled;
        
        #if (PROJECTM_VERSION_INT >= 3000000)
        float waveScale;
        char hardCutsEnabled;
        float hardCutDuration;
        float hardCutSensitivity;
        #endif
    };
    #endif

    typedef void* projectM_ptr;

    DLLEXPORT projectM_ptr projectM_create1(char* config_file);
    
    #if (PROJECTM_VERSION_INT < 1000000 || PROJECTM_VERSION_INT >= 2000000)
    DLLEXPORT projectM_ptr projectM_create2(int gx, int gy, int fps, int texsize, 
                        int width, int height, char* preset_url, 
                        char* title_fonturl, char* title_menuurl);
    #endif

    DLLEXPORT void projectM_resetGL(projectM_ptr pm, int width, int height);
    DLLEXPORT void projectM_renderFrame(projectM_ptr pm);
    DLLEXPORT unsigned projectM_initRenderToTexture(projectM_ptr pm); 
    
    DLLEXPORT void projectM_key_handler(projectM_ptr pm, projectMEvent event, 
                    projectMKeycode keycode, projectMModifier modifier);
    
    DLLEXPORT void PCM_addPCMfloat(projectM_ptr pm, float *PCMdata, int samples);
    DLLEXPORT void PCM_addPCM16(projectM_ptr pm, short [2][512]);
    DLLEXPORT void PCM_addPCM16Data(projectM_ptr pm, const short* pcm_data, short samples);
    DLLEXPORT void PCM_addPCM8(projectM_ptr pm, unsigned char [2][1024]);
    DLLEXPORT void PCM_addPCM8_512(projectM_ptr pm, const unsigned char [2][512]);

    #if (PROJECTM_VERSION_INT > 1000000)
    DLLEXPORT void projectM_settings(projectM_ptr pm, Settings* settings);
    #endif

    #if (PROJECTM_VERSION_INT >= 2000000)
    DLLEXPORT void projectM_setPresetDuration(projectM_ptr pm, float seconds);
    DLLEXPORT float projectM_getPresetDuration(projectM_ptr pm);
    DLLEXPORT void projectM_setBeatSensitivity(projectM_ptr pm, float sensitivity);
    DLLEXPORT float projectM_getBeatSensitivity(projectM_ptr pm);
    #endif

    DLLEXPORT void projectM_setTitle(projectM_ptr pm, char* title);
    
    DLLEXPORT void projectM_free(projectM_ptr pm);

    #if (PROJECTM_VERSION_INT >= 3000000)
    DLLEXPORT void projectM_enableHardCuts(projectM_ptr pm, int enable);
    DLLEXPORT int projectM_hardCutsEnabled(projectM_ptr pm);
    DLLEXPORT void projectM_setHardCutDuration(projectM_ptr pm, float seconds);
    DLLEXPORT float projectM_getHardCutDuration(projectM_ptr pm);
    #endif
}

#endif