;;; -*- coding:utf-8 -*-
;; (eval-when-compile
;;   (require 'joseph_byte_compile_include)
;;   (require 'org)
;;   ;; (require 'org-html nil t)
;;   (require 'ox-html nil t)
;;   (require 'yasnippet)
;;   (require 'joseph-outline-lazy))

;; (require 'org-publish nil t)
(require 'ox-publish nil t)
(require 'ox-org nil t)
(require 'ob-ditaa nil t)

(setq user-emacs-directory (expand-file-name "."))
;;  第三方package相关配置
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
;; (add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t) ; Org-mode's repository
;; make sure to have downloaded archive description.
;; Or use package-archive-contents as suggested by Nicolas Dudebout
(or (file-exists-p package-user-dir) (package-refresh-contents))
;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(if (equal system-type 'gnu/linux)
    (setq dired-listing-switches "--time-style=+%y-%m-%d/%H:%M  --group-directories-first -alhG")
  (setq dired-listing-switches "-alhG"))
(when (eq system-type 'darwin)
  (require 'ls-lisp)
  (setq-default ls-lisp-use-insert-directory-program nil))



;;; the following is only needed if you install org-page manually
(require 'org-page)

(setq org-confirm-babel-evaluate nil)

(setq op/site-main-title "一个人的狂欢")
(setq op/site-sub-title "")
(setq op/personal-github-link "http://github.com/jixiuf")
(setq op/repository-directory "..")
(setq op/site-domain "http://jixiuf.github.io")
;;; for commenting, you can choose either disqus or duoshuo
(setq op/personal-disqus-shortname "jixiuf")
(setq op/personal-duoshuo-shortname "jixiuf")
(setq op/theme-root-directory "./org-page-themes")
(setq op/theme 'jixiuf_theme)
(setq op/highlight-render 'htmlize)
;;; the configuration below are optional
;; (setq op/personal-google-analytics-id "jixiuf")


;; (require 'org-exp-blocks nil t)           ;#+BEGIN_DITAA hello.png -r -S -E 要用到
(setq org-ditaa-jar-path (expand-file-name "./ditaa.jar"))
(with-eval-after-load 'org-exp-blocks  (add-to-list 'org-babel-load-languages '(ditaa . t)))

;; (declare-function org-publish "ox-publish")
;; (declare-function yas-global-mode "yasnippet")


;;;###autoload
(defun publish-my-note-recent(&optional n)
  "发布我的`note'笔记"
  (interactive "p")
  (when (zerop n) (setq n 1))
  (save-some-buffers)
  (dolist (b (buffer-list))
    (when (and (buffer-file-name b)
               (file-in-directory-p (buffer-file-name b) op/repository-directory))
      (kill-buffer b)))
  (op/do-publication nil (format "HEAD^%d" n) t nil)
  ;; (publish-single-project "note-src")
  ;; ;; (publish-my-note-html)
  ;; (publish-single-project "note-html")
  ;; (view-sitemap-html-in-brower)
  (dired op/repository-directory))

;;;###autoload
(defun publish-my-note-local-preview()
  "发布我的`note'笔记"
  (interactive)
  (save-some-buffers)
  (dolist (b (buffer-list))
    (when (and (buffer-file-name b)
               (file-in-directory-p (buffer-file-name b) op/repository-directory))
      (kill-buffer b)))
  (call-interactively 'op/do-publication-and-preview-site)
  (dired op/repository-directory))
;;;###autoload

(defun publish-my-note-all()
  "发布我的`note'笔记"
  (interactive)
  (save-some-buffers)
  (dolist (b (buffer-list))
    (when (and (buffer-file-name b)
               (file-in-directory-p (buffer-file-name b) op/repository-directory))
      (kill-buffer b)))
  (op/do-publication t nil t t)
  (dired op/repository-directory))



(setq op/category-ignore-list  '("themes" "assets" "daily" "style" "img" "js" "author" "download"
                                 "docker" "build"
                                 "nginx" "cocos2dx" "mac"
                                 "Linux" "autohotkey" "c"   "emacs" "emacs_tutorial" "erlang" "git" "go" "java" "mysql"
                                 "oracle" "passhash.htm" "perl" "sqlserver"  "svn" "windows"))


(setq-default op/category-config-alist
  '(("blog" ;; this is the default configuration
    :show-meta t
    :show-comment t
    :uri-generator op/generate-uri
    :uri-template "/blog/%t/"
    :sort-by :date     ;; how to sort the posts
    :category-index t) ;; generate category index or not
   ("index"
    :show-meta nil
    :show-comment nil
    :uri-generator op/generate-uri
    :uri-template "/"
    :sort-by :date
    :category-index nil)
   ("about"
    :show-meta nil
    :show-comment nil
    :uri-generator op/generate-uri
    :uri-template "/about/"
    :sort-by :date
    :category-index nil)))


;; (add-to-list 'op/category-config-alist
;;              '("sitemap"
;;               :show-meta nil
;;               :show-comment nil
;;               :uri-generator op/generate-uri
;;               :uri-template "/blog/sitemap"
;;               :sort-by :date
;;               :category-index nil)
;;              )


(defun jixiuf-get-file-category (org-file)
  "Get org file category presented by ORG-FILE, return all categories if
ORG-FILE is nil. This is the default function used to get a file's category,
see `op/retrieve-category-function'. How to judge a file's category is based on
its name and its root folder name under `op/repository-directory'."
  (cond ((not org-file)
         (let ((cat-list '("index" "about" "blog"))) ;; 3 default categories
           (dolist (f (directory-files op/repository-directory))
             (when (and (not (equal f "."))
                        (not (equal f ".."))
                        (not (equal f ".git"))
                        (not (member f op/category-ignore-list))
                        (not (equal f "blog"))
                        (file-directory-p
                         (expand-file-name f op/repository-directory)))
               (setq cat-list (cons f cat-list))))
           cat-list))
        ((string= (expand-file-name "index.org" op/repository-directory)
                  (expand-file-name org-file)) "index")
        ;; ((string= (expand-file-name "sitemap.org" op/repository-directory)
        ;;           (expand-file-name org-file)) "sitemap")
        ((string= (expand-file-name "about.org" op/repository-directory)
                  (expand-file-name org-file)) "about")
        ((string= (file-name-directory (expand-file-name org-file))
                  op/repository-directory) "blog")

        (t "blog"                       ;changed by me ,默认都算到blog 下
           ;; (car (split-string (file-relative-name (expand-file-name org-file)
           ;;                                                   op/repository-directory)
           ;;                               "[/\\\\]+"))
           )))

(fset 'op/get-file-category 'jixiuf-get-file-category)
(setq op/retrieve-category-function 'jixiuf-get-file-category)

(provide 'org-publish)
