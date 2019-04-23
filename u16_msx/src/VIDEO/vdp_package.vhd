--
--  vdp_package.vhd
--   Package file of ESE-VDP.
--
--  Copyright (C) 2000-2006 Kunihiko Ohnaka
--  All rights reserved.
--                                     http://www.ohnaka.jp/ese-vdp/
--
--  �{�\�t�g�E�F�A�����і{�\�t�g�E�F�A�Ɋ��Â��č쐬���ꂽ�h�����́A�ȉ��̏��
--  �������ꍇ�Ɍ���A�ĔЕz�����юg�p���������܂��B
--
--  1.�\�[�X�R�[�h�`���ōĔЕz�����ꍇ�A���L�̒��쌠�\���A�{��ꗗ�A�����щ��L
--    �Ɛӏ��̂܂܂̌`�ŕێ����邱�ƁB
--  2.�o�C�i���`���ōĔЕz�����ꍇ�A�Еz���ɕt���̃h�L�������g���̎����ɁA���L��
--    ���쌠�\���A�{��ꗗ�A�����щ��L�Ɛӏ���܂߂邱�ƁB
--  3.���ʂɂ��鎖�O�̋��Ȃ��ɁA�{�\�t�g�E�F�A���̔��A�����я��ƓI�Ȑ��i�⊈��
--    �Ɏg�p���Ȃ����ƁB
--
--  �{�\�t�g�E�F�A�́A���쌠�҂ɂ���āu�����̂܂܁v�񋟂����Ă��܂��B���쌠�҂́A
--  ����ړI�ւ̓K�����̕ۏ؁A���i���̕ۏ؁A�܂������Ɍ�肳���Ȃ��A�����Ȃ閾��
--  �I�����͈ÖقȕۏؐӔC�����܂����B���쌠�҂́A���R�̂����������킸�A���Q
--  �����̌�����������킸�A���ӔC�̍������_���ł��邩���i�ӔC�ł��邩�i�ߎ�
--  ���̑��́j�s�@�s�ׂł��邩�����킸�A���ɂ��̂悤�ȑ��Q�����������\�����m��
--  �����Ă����Ƃ��Ă��A�{�\�t�g�E�F�A�̎g�p�ɂ���Ĕ��������i���֕i�܂��͑��p�T
--  �[�r�X�̒��B�A�g�p�̑r���A�f�[�^�̑r���A���v�̑r���A�Ɩ��̒��f���܂߁A�܂���
--  ���Ɍ�肳���Ȃ��j���ڑ��Q�A�Ԑڑ��Q�A��I�ȑ��Q�A��ʑ��Q�A�����I���Q�A��
--  ���͌��ʑ��Q�ɂ��āA���ؐӔC�𕉂��Ȃ����̂Ƃ��܂��B
--
--  Note that above Japanese version license is the formal document.
--  The following translation is only for reference.
--
--  Redistribution and use of this software or any derivative works,
--  are permitted provided that the following conditions are met:
--
--  1. Redistributions of source code must retain the above copyright
--     notice, this list of conditions and the following disclaimer.
--  2. Redistributions in binary form must reproduce the above
--     copyright notice, this list of conditions and the following
--     disclaimer in the documentation and/or other materials
--     provided with the distribution.
--  3. Redistributions may not be sold, nor may they be used in a 
--     commercial product or activity without specific prior written
--     permission.
--
--  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
--  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
--  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
--  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
--  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
--  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
--  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
--  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
--  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
--  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
--  POSSIBILITY OF SUCH DAMAGE.
--
-------------------------------------------------------------------------------
-- Memo
--   Japanese comment lines are starts with "JP:".
--   JP: ���{���̃R�����g�s�� JP:�𓪂ɕt���鎖�ɂ���
--
-------------------------------------------------------------------------------
-- Revision History
--
-- 29th,October,2006 modified by Kunihiko Ohnaka
--   - Insert the license text.
--   - Add the document part below.
--
-------------------------------------------------------------------------------
-- Document
--
-- JP: ESE-VDP�̃p�b�P�[�W�t�@�C���ł��B
-- JP: ESE-VDP�Ɋ܂܂��郂�W���[���̃R���|�[�l���g�錾���A�萔�錾�A
-- JP: �^�ϊ��p�̊֐��Ȃǂ����`�����Ă��܂��B
--

LIBRARY IEEE;
	USE IEEE.STD_LOGIC_1164.ALL;
	USE IEEE.STD_LOGIC_UNSIGNED.ALL;

PACKAGE VDP_PACKAGE IS

	-- VDP ID
--	CONSTANT VDP_ID : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00000";  -- V9938
--	CONSTANT VDP_ID : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00001";  -- UNKNOWN
	CONSTANT VDP_ID : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00010";  -- V9958

	-- display start position ( when adjust=(0,0) )
	-- [from V9938 Technical Data Book]
	-- Horaizontal Display Parameters
	--  [non TEXT]
	--   * Total Display      1368 clks  - a
	--   * Right Border         59 clks  - b
	--   * Right Blanking       27 clks  - c
	--   * H-Sync Pulse Width  100 clks  - d
	--   * Left Blanking       102 clks  - e
	--   * Left Border          56 clks  - f
	-- OFFSET_X is the position when preDotCounter_x is -8. So,
	--    => (d+e+f-8*4-8*4)/4 => (100+102+56)/4 - 16 => 49
	--
	-- Vertical Display Parameters (NTSC)
	--                            [192 Lines]  [212 Lines]
	--                            [Even][Odd]  [Even][Odd]
	--   * V-Sync Pulse Width          3    3       3    3 lines - g
	--   * Top Blanking               13 13.5      13 13.5 lines - h
	--   * Top Border                 26   26      16   16 lines - i
	--   * Display Time              192  192     212  212 lines - j
	--   * Bottom Border            25.5   25    15.5   15 lines - k
	--   * Bottom Blanking             3    3       3    3 lines - l
	-- OFFSET_Y is the start line of Top Border (192 LInes Mode)
	--    => l+g+h => 3 + 3 + 13 = 19
	--
	-- CLOCK PER LINE
	-- JP: 4�̔{���łȂ����΂Ȃ��Ȃ�
	CONSTANT CLOCKS_PER_LINE	: INTEGER := 1368;								-- = 342*4

	-- LEFT-TOP POSITION OF VISIBLE AREA
	CONSTANT OFFSET_X			: STD_LOGIC_VECTOR( 6 DOWNTO 0) := "0110010";	-- = 50
	CONSTANT OFFSET_Y			: STD_LOGIC_VECTOR( 6 DOWNTO 0) := "0010011";	-- = 19
END VDP_PACKAGE;
