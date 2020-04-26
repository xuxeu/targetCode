#���ļ����û����ӹ�������ʹ��
include tc_makefile.mk
include ../config_monitor.mk
include  $(RTOS_PATH)/base.make
WIND_HOME := E:/platform
WIND_BASE := E:/platform/target
TEMP := C:\DOCUME~1\ADMINI~1\LOCALS~1\Temp

RM := rm -rf

#ǰ����Щ������ǰ��vmakefile�ж����,������������ֲ��makefile�ж���
# ����Щ�����������������������������
#�õ���ǰ��·��
ifeq (${ARCH},x86)
	CONFIG_SUB_ARCH = pentium4
endif
CURRENTDIR:=${RTOS_PATH}/tools/monitor

#������ʾ����ѡ��
ifeq (${ARCH},mips)
	CONFIG_TA_DISPLAY_DEVICE_TYPE := VGA
endif

#ƽִ̨���ļ�·��
#PLATFORM_BIN :=$(PLATFORM)/host/deltaos/bin

#����ta/src/includeΪ����ͷ�ļ�·��
#������Ҫ���ݾ����ARCH�궨�����ָ��

INCLUDE_PATHS = -I$(CURRENTDIR) \
			-I$(RTOS_PATH)/include/debug \
			-I$(RTOS_PATH)/include/debug/$(CONFIG_ARCH) \
			-I$(CURRENTDIR)/src/board/${ARCH}/${TARGT_BOARD}/include \
			-I$(RTOS_PATH)/include/vxworks   \
			-I$(RTOS_PATH)/include/vxworks/private   \
			-I$(RTOS_PATH)/include/vxworks/types   \
			-I$(RTOS_PATH)/include/usr/h/ \
			-I$(RTOS_PATH)/include/usr/h/private \
			-I$(RTOS_PATH)/include/DeltaCore \
			
#�������
CFLAGS := $(CFLAGS) $(INCLUDE_PATHS)

VSB_LIB_NAME := lib

FLAGS :=  -L$(RTOS_PATH)/$(VSB_LIB_NAME)/$(TARGET_ADAPT_LIB)/$(ARCH)/$(CONFIG_SUB_ARCH)/$(CONFIG_CPU_ENDIAN) -N -T $(PROJECT_PATH)/$(TARGT_BOARD)/catlinkcmds -Map map.txt 
LDFLAGS = FLAGS
PREFLAGS :=  -L$(RTOS_PATH)/$(VSB_LIB_NAME)/$(TARGET_ADAPT_LIB)/$(ARCH)/$(CONFIG_SUB_ARCH)/$(CONFIG_CPU_ENDIAN) -N -T $(PROJECT_PATH)/$(TARGT_BOARD)/prelinkcmds -Map map.txt

#����ѹ���ļ�·��	
INPUT_ARCHIVES = libtra.a
ARCHIVES := $(INPUT_ARCHIVES)

#�������ɿ�ִ���ļ���tra.��׺
EXECUTABLES += ../tra
TARGET_EXT +=bin

#��Ҫ���빹����Դ�����·��
SRC_PATHS = ../src \
			../src/board \
			../src/board/${ARCH} \
			../src/board/${ARCH}/${TARGT_BOARD} \
			../src/board/${ARCH}/${TARGT_BOARD}/driver \
			../src/board/${ARCH}/${TARGT_BOARD}/start \
			../src/board/${ARCH}/${TARGT_BOARD}/arch \
			../src/init \
			../src/communication

#����Դ����·���ҵ�����Ҫ�ı��빹��������Դ����
SRC_FILES = $(notdir ${wildcard $(patsubst %, %/*.c, $(SRC_PATHS))}  \
            ${wildcard $(patsubst %, %/*.S, $(SRC_PATHS))} )

#��������ѡ������ĸ���������
ifeq ($(CONFIG_TA_ETHER_TYPE), INTEL8254X)
	SRC_FILES := ${subst taIntel8255x.c,, ${SRC_FILES}}
	SRC_FILES := ${subst taAm79C97X.c,, ${SRC_FILES}}
	SRC_FILES := ${subst taEth8139.c,, ${SRC_FILES}}	
endif
ifeq ($(CONFIG_TA_ETHER_TYPE), INTEL8255X)
	SRC_FILES := ${subst taIntel8254x.c,, ${SRC_FILES}}
	SRC_FILES := ${subst taAm79C97X.c,, ${SRC_FILES}}
	SRC_FILES := ${subst taEth8139.c,, ${SRC_FILES}}	
endif
ifeq ($(CONFIG_TA_ETHER_TYPE), RTL8139)
	SRC_FILES := ${subst taIntel8254x.c,, ${SRC_FILES}}
	SRC_FILES := ${subst taIntel8255x.c,, ${SRC_FILES}}
	SRC_FILES := ${subst taAm79C97X.c,, ${SRC_FILES}}	
endif
ifeq ($(CONFIG_TA_ETHER_TYPE), LN97)
	SRC_FILES := ${subst taIntel8254x.c,, ${SRC_FILES}}
	SRC_FILES := ${subst taIntel8255x.c,, ${SRC_FILES}}
	SRC_FILES := ${subst taEth8139.c,, ${SRC_FILES}}	
endif

ifeq ($(CONFIG_TA_DISPLAY_DEVICE_TYPE), VGA)
	SRC_FILES := ${subst taDVI.c,, ${SRC_FILES}}	
endif
ifeq ($(CONFIG_TA_DISPLAY_DEVICE_TYPE), DVI)
	SRC_FILES := ${subst taVga.c,, ${SRC_FILES}}	
endif

#����*.o �ļ��� *.c �ļ���������ϵ
OBJS = ${patsubst %.c,%.o,${patsubst %.S,%.o,${SRC_FILES}}} 

#����ARCH�ʹ�С�������������������Ӳ���
ifeq (${ARCH},x86)
	CFLAGS += -DCONFIG_CORE_SMP
	CFLAGS += -DTA_ARCH_X86
	CFLAGS += -D__X86__
	CFLAGS += -DCONFIG_CORE_SMP
	 
	ifeq (${CONFIG_CPU_ENDIAN},big)
		CFLAGS +=   -D__BIG_ENDIAN__
	endif
	
	ifeq (${CONFIG_CPU_ENDIAN},little)
	 	CFLAGS += -D__LITTLE_ENDIAN__
	endif
endif

ifeq (${ARCH},ppc)
 	CFLAGS += -DTA_ARCH_PPC
	CFLAGS += -D__PPC__
	ifeq (${CONFIG_CPU_ENDIAN},big)
		CFLAGS += -D__BIG_ENDIAN__ 
		FLAGS +=  -EB
		PREFLAGS += -EB
	endif
	
	ifeq (${CONFIG_CPU_ENDIAN},little)
	 	CFLAGS += -mlittle-endian  -D__LITTLE_ENDIAN__
		FLAGS +=  -EL
		PREFLAGS += -EL
	endif
endif

ifeq (${ARCH},mips)
	CFLAGS += -DCONFIG_CORE_SMP -D_KERNEL_DEBUG_
 	CFLAGS += -DTA_ARCH_MIPS
	CFLAGS += -G 0 -mno-branch-likely -mips3 -mabi=n32 -mgp64 -D__MIPS__ -DLS3_HT -DMIPSEL -DCPU=MIPS64 -DTOOL_FAMILY=gnu -DTOOL=gnule
	ifeq (${CONFIG_CPU_ENDIAN},big)
		CFLAGS += -D__BIG_ENDIAN__ 
		FLAGS +=  -EB
		PREFLAGS += -EB
	endif
	
	ifeq (${CONFIG_CPU_ENDIAN},little)
	 	CFLAGS += -EL -D__LITTLE_ENDIAN__
		FLAGS +=  -EL
		PREFLAGS += -EL
	endif
endif

#���������������������
ifeq (${CONFIG_CPU_ENDIAN},big)
	CFLAGS +=  
endif

ifeq (${CONFIG_CPU_ENDIAN},little)
 	CFLAGS += 
endif

#������Ӳ���������ж���Ӳ����ı�����������
TA_CC_FLOAT = 
TA_LD_FLOAT = 

ifeq (${CPU_FLOAT},hard)
	TA_CC_FLOAT := 
endif

ifeq (${CPU_FLOAT},soft)
	TA_CC_FLOAT := -msoft-float
endif

ifeq (${CPU_FLOAT},hard)
	TA_LD_FLOAT := -lc -lm
endif

ifeq (${CPU_FLOAT},soft)
	TA_LD_FLOAT := -lc_soft -lm_soft
endif

###################
LINK_OBJS = crt0.o
ifeq (${ARCH},ppc)
	LINK_OBJS = crt0.o vector.o
endif

##################


#����ǰ����ж��������ı������Ӳ���
#ifeq (${ARCH},mips)
#	CFLAGS +=  -I$(CURRENTDIR)/../ -I$(CURRENTDIR)/../src $(COMPILE_DEBUG) $(COMPILE_WARNING) $(TA_CC_FLOAT) \
#	-DUINT32=unsigned -DINT8=char -DBOOL=int -DUINT8=unsigned\ char -DUINT16=unsigned\ short -G 0 -mips3 -D__MIPS__ \
#	-DMIPSEL -DCPU=MIPS64 -DTOOL_FAMILY=gnu -DTOOL=gnule
#endif
ifeq (${ARCH},x86)
	ifeq ($(CPU_BIT), 64)
		LIBS := -lgcc64
	endif
endif

ifeq ($(CPU_BIT), 32)
	LIBS := -lgcc32
endif

ifeq (${ARCH},x86)
	LIBS := -lgcc
endif

ifneq (${ARCH},mips)
	LIBS += $(TA_LD_FLOAT)
endif

LIBS += -lkda -ltautil

#�������þ��������ļ������պ�׺�������ɷ�ʽ
TA_EXECUTABLE_SUFFIX = 

ifeq (${ARCH},x86)
	TA_EXECUTABLE_SUFFIX := exe
endif

ifeq (${ARCH},ppc)
 	TA_EXECUTABLE_SUFFIX := bin
endif

ifeq (${ARCH},mips)
 	TA_EXECUTABLE_SUFFIX := elf
endif

# All Target
all : clean  $(EXECUTABLES).$(TA_EXECUTABLE_SUFFIX) finish

beforebuild :
	@echo "*********************************"
	@$(PLATFORM)/host/pub/TraTool ./config_ta.h

#����elf�ļ���bin�ļ�������������ϵ
$(EXECUTABLES).bin : $(EXECUTABLES).elf
	@echo 'Building target: $@'
ifeq (${ARCH},x86)
	@$(OBJCOPY) -O binary --strip-unneeded  -R .note -R .comment $<  $@
endif

ifeq (${ARCH},ppc)
	@$(OBJCOPY).exe -I elf32-powerpc -O binary -S ../tra.elf ../tra.bin
endif

#����elf�ļ���exe�ļ���������ϵ
$(EXECUTABLES).exe : $(EXECUTABLES).elf
	@echo 'Building target: $@'
	@echo $(OBJCOPY) -O elf32-i386-vxworks --strip-debug -R .note -R .comment -R .stab -R .stabstr -R .jcr -R .rodata.str1.4 -R .rodata.str1.1 $<  $@
	@$(OBJCOPY) -O elf32-i386-vxworks --strip-debug -R .note -R .comment -R .stab -R .stabstr -R .jcr -R .rodata.str1.4 -R .rodata.str1.1 $<  $@
	@echo 'Finished building target'

#����.a�ļ���elf�ļ�������������ϵ
$(EXECUTABLES).elf : $(ARCHIVES)
	@echo 'Building target: $@'
	@echo 'Invoking: GCC C Linker'
	@echo "(PREFLAGS) $(PREFLAGS)"
	@echo "(FLAGS) $(FLAGS)"
	@echo $(LD) $(FLAGS) $(LINK_OBJS) $(USER_OBJS) --start-group $< $(LIBS) --end-group  -o $@
	@$(LD) $(FLAGS) $(LINK_OBJS) $(USER_OBJS) --start-group $< $(LIBS) --end-group  -o $@
	@echo $(SIZE) -A -x $@ 1>presize.txt
	@$(SIZE) -A -x $@ 1>presize.txt
	@echo 'Finished building target: $@'
	
#����.o�ļ���.a�ļ�������������ϵ
$(ARCHIVES):
	@echo 'Invoking: GCC Archiver'
	${MAKE} "CFLAGS := $(CFLAGS) " "L_OBJS=$(OBJS) " "L_NAME :=$(INPUT_ARCHIVES)" "L_PATH :=$(PROJECT_PATH)/.make" "VPATH = $(SRC_PATHS)" $(INPUT_ARCHIVES) -f $(RTOS_PATH)/Rules.make
	@echo "CFLAGS = $(CFLAGS)"
	@echo 'Finished building: $@'

#��������
clean:
ifeq ($(TARGET_EXT),elf)
	-$(RM) $(OBJS) $(ARCHIVES) $(DEPS)$(EXECUTABLES).elf
endif

ifeq ($(TARGET_EXT),bin)
	-$(RM) $(OBJS) $(ARCHIVES) $(DEPS)$(EXECUTABLES).bin $(EXECUTABLES).elf
endif

ifeq ($(TARGET_EXT),exe)
	-$(RM) $(OBJS) $(ARCHIVES) $(DEPS)$(EXECUTABLES).exe $(EXECUTABLES).elf
endif

finish:
	-$(RM) $(OBJS) $(ARCHIVES)

.PHONY: all clean dependents beforebuild
.SECONDARY: