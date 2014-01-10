sudo yaourt -S --noconfirm git vim rxvt-unicode cmake ctags-svn python2
git clone https://github.com/KenjiTakahashi/dotfiles.git
git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
cp dotfiles/dotvimrc .vimrc
vim -E -c BundleInstall -c qall
mkdir ~/.vim/ycm
cd ~/.vim/ycm
cmake -G "Unix Makefiles" ~/.vim/bundle/YouCompleteMe/cpp
make ycm_support_libs
cd
rm -rf ~/.vim/ycm
